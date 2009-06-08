From: David Miller <davem@davemloft.net>
Subject: Re: net: Ensure partial checksum offset is inside the skb head
Date: Mon, 08 Jun 2009 00:23:03 -0700 (PDT)
Message-ID: <20090608.002303.109546042.davem@davemloft.net>
References: <20090604110600.GA28453@gondor.apana.org.au>
	<20090604112201.GA28820@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rusty@rustcorp.com.au
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51752
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752171AbZFHHXB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 03:23:01 -0400
In-Reply-To: <20090604112201.GA28820@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 4 Jun 2009 21:22:01 +1000

> On Thu, Jun 04, 2009 at 09:06:00PM +1000, Herbert Xu wrote:
>> 
>> tun: Optimise handling of bogus gso->hdr_len
>> 
>> As all current versions of virtio_net generate a value for the
>> header length that's too small, we should optimise this so that
>> we don't copy it twice.  This can be done by ensuring that it is
>> at least as large as the place where we'll write the checksum.
>> 
>> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> With this applied we can strengthen the partial checksum check:
> 
> net: Ensure partial checksum offset is inside the skb head
> 
> In skb_partial_csum_set we check to see if the checksum offset
> is within the packet.  However, we really should check that it
> is within the skb head as that's the only bit we can modify
> without copying.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
