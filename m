From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next-2.6] packet: Add GSO/checksum offload support
	to af_packet sockets
Date: Sat, 30 Jan 2010 10:22:12 +1100
Message-ID: <20100129232212.GA7333@gondor.apana.org.au>
References: <1264537819.24933.122.camel@w-sridhar.beaverton.ibm.com> <20100129085343.GB23140@gondor.apana.org.au> <1264800308.15980.395.camel@w-sridhar.beaverton.ibm.com> <20100129213619.GA6404@gondor.apana.org.au> <4B636199.7080708@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	netdev <netdev@vger.kernel.org>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34325 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752339Ab0A2XW1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 18:22:27 -0500
Content-Disposition: inline
In-Reply-To: <4B636199.7080708@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 29, 2010 at 02:30:49PM -0800, Sridhar Samudrala wrote:
>
> In this use-case, the component that is calling sendmsg() can be either  
> the vhost-net in host kernel
> or qemu. They get the buffer including the L2 header from the guest.  
> They too need to parse the L2
> header to find the protocol.

So have them parse the L2 header to get the protocol.  They know
that the packet should contain an Ethernet header, while this
knowledge would be inappropriate for af_packet in general.

This is also why we call eth_type_trans in network drivers as
opposed to the core.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
