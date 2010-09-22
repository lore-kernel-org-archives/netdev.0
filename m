From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip : take care of last fragment in ip_append_data
Date: Tue, 21 Sep 2010 21:53:37 -0700 (PDT)
Message-ID: <20100921.215337.232739449.davem@davemloft.net>
References: <1285049787.2323.797.camel@edumazet-laptop>
	<20100921.163856.71124744.davem@davemloft.net>
	<1285130646.6378.45.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nbowler@elliptictech.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39264
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750899Ab0IVExS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 00:53:18 -0400
In-Reply-To: <1285130646.6378.45.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 22 Sep 2010 06:44:06 +0200

> The "17" (instead of probable 16 need) comes from :
> 
> net/ipv4/esp4.c line 599 :
> 
> x->props.trailer_len = align + 1 + crypto_aead_authsize(esp->aead);
> 
> In my Nick ipsec script case, 
> crypto_aead_blocksize(aead) = 16, 
> crypto_aead_authsize(esp->aead) = 0
> 
> -> align = 16
> trailer_len = 16 + 1 + 0;
> 
> I am not sure we need the "+ 1", but I know nothing about this stuff.
> 
> Same in net/ipv6/esp6.c ?

I think the author of this code thought that the alignment was
expressed as "N - 1" instead of plain "N".

I'll do some research. :-)

Thanks Eric.
