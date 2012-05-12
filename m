From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] codel: use Newton method instead of sqrt()
 and divides
Date: Sat, 12 May 2012 22:40:56 +0200
Message-ID: <1336855256.31653.1329.camel@edumazet-glaptop>
References: <1336829533.31653.1108.camel@edumazet-glaptop>
	 <20120512.155259.1178343836887150194.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: dave.taht@bufferbloat.net, netdev@vger.kernel.org,
	nichols@pollere.com, van@pollere.net, codel@lists.bufferbloat.net,
	ycheng@google.com, mattmathis@google.com, therbert@google.com,
	shemminger@vyatta.com, nanditad@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:43909 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756512Ab2ELUlE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 May 2012 16:41:04 -0400
Received: by wgbdr13 with SMTP id dr13so3468968wgb.1
        for <netdev@vger.kernel.org>; Sat, 12 May 2012 13:41:03 -0700 (PDT)
In-Reply-To: <20120512.155259.1178343836887150194.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-05-12 at 15:52 -0400, David Miller wrote:

> Applied but I never like that bitfield sharing for real integers.
> 
> GCC makes a complete mess of it as it extracts and inserts the
> integer value into that bit field.  You are guarenteed to get
> better code if you do this by hand in a full u32.
> 
> Either that or just bite the bullet and use a completely seperate
> field, maybe we'll need more boolean states later.

I couldnt use a full u32 or else fq_codel cell was > 64 bytes (or I
would have to remove the 'dropped' field)

24 bit of precision for the reciprocal value is more than enough (Van
suggested 16 bits in fact), so we have actually room for 7 bits if
needed.

By the way, gcc on x86 generates nice "and 0xfffffffe,%eax" instruction
for (vars->rec_inv_sqrt << 1).

Thanks
