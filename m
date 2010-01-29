From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next-2.6] packet: Add GSO/checksum offload support
	to af_packet sockets
Date: Sat, 30 Jan 2010 08:36:19 +1100
Message-ID: <20100129213619.GA6404@gondor.apana.org.au>
References: <1264537819.24933.122.camel@w-sridhar.beaverton.ibm.com> <20100129085343.GB23140@gondor.apana.org.au> <1264800308.15980.395.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	netdev <netdev@vger.kernel.org>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33728 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752554Ab0A2Vge (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 16:36:34 -0500
Content-Disposition: inline
In-Reply-To: <1264800308.15980.395.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 29, 2010 at 01:25:08PM -0800, Sridhar Samudrala wrote:
> 
> This check is to dis-allow processing of packets with virtio_net_hdr
> destined for non-ethernet devices.
> Is it OK if i add a check in packet_bind() to not allow binding to
> a non-ethernet device when PACKET_VNET_HDR option is set?
> 
> I need to figure out a way to set the skb protocol correctly based
> on the packet. Any clues?

IMHO the skb protocol should be set by whatever is invoking the
sendmsg call.  After all they would know what the L2 header is
and should be able to deduce the protocol correctly.

Adding all this logic into AF_PACKET is just a hack.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
