From: Patrick McHardy <kaber@trash.net>
Subject: Re: dhcp client packet sniffing...
Date: Thu, 08 Apr 2010 14:49:49 +0200
Message-ID: <4BBDD0ED.1010203@trash.net>
References: <20100408.035049.177640912.davem@davemloft.net> <20100408114738.GA23329@gondor.apana.org.au> <20100408.051144.183699401.davem@davemloft.net> <20100408123025.GA23762@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36636 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758636Ab0DHMtz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 08:49:55 -0400
In-Reply-To: <20100408123025.GA23762@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Thu, Apr 08, 2010 at 05:11:44AM -0700, David Miller wrote:
>> We have the socket pointer etc. already in dev_queue_xmit_nit(), so we
>> can easily do it.
> 
> It doesn't look trivial to me since AF_PACKET fiddles with packet
> headers before running the filter...

Yes, that looks difficult. What might work is to pass the skb->data
offsets resulting from those modifications to sk_run_filter to
adjust the postition when loading data from the packet. That would
allow to run the filter on the original packet before cloning it.

Regarding your idea of only receiving incoming packets, userspace could
use the SKF_AD_PKTTYPE filter with PACKET_HOST. During filter attachment
and checks, we could mark the socket as only interested in incoming or
outgoing packets.

This would require userspace changes of course, but we should be able
to avoid passing outgoing packets to af_packet with very low overhead.
