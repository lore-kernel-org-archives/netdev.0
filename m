From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: dhcp client packet sniffing...
Date: Thu, 8 Apr 2010 21:12:54 +0800
Message-ID: <20100408131254.GA24262@gondor.apana.org.au>
References: <20100408.035049.177640912.davem@davemloft.net> <20100408114738.GA23329@gondor.apana.org.au> <20100408.051144.183699401.davem@davemloft.net> <20100408123025.GA23762@gondor.apana.org.au> <4BBDD0ED.1010203@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:60954 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758711Ab0DHNNC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 09:13:02 -0400
Content-Disposition: inline
In-Reply-To: <4BBDD0ED.1010203@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 08, 2010 at 02:49:49PM +0200, Patrick McHardy wrote:
> 
> Yes, that looks difficult. What might work is to pass the skb->data
> offsets resulting from those modifications to sk_run_filter to
> adjust the postition when loading data from the packet. That would
> allow to run the filter on the original packet before cloning it.

The thing is we can't express those offsets as constants so we'll
need to run protocol-specific code (i.e., an indirect function
call) prior to calling the filter.

At that point I'd just give up and go back to the skb_share idea :)

If we're concerned about atomic counter performance, we could even
do a non-atomic version of skb_share and use it here.  We're the
sole owner of the skb at this point.

> Regarding your idea of only receiving incoming packets, userspace could
> use the SKF_AD_PKTTYPE filter with PACKET_HOST. During filter attachment
> and checks, we could mark the socket as only interested in incoming or
> outgoing packets.
> 
> This would require userspace changes of course, but we should be able
> to avoid passing outgoing packets to af_packet with very low overhead.

As kernel programmers, we reject in principle any solution that
involves user-space coding :)

Seriously, with the number of DHCP clients out there, any solution
that requires changing the client is not going to achieve the
objective in a reasonable time-frame.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
