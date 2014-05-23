From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] enic: fix adaptive irq coalescing on 32-bit
Date: Fri, 23 May 2014 11:29:15 +0200
Message-ID: <14330971.FOHpOT3kal@wuerfel>
References: <10713072.kCczZxGWdQ@wuerfel> <063D6719AE5E284EB5DD2968C1650D6D1724C45F@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sujith Sankar <ssujith@cisco.com>,
	Neel Patel <neepatel@cisco.com>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	"David S. Miller" <davem@davemloft.net>,
	Christian Benvenuti <benve@cisco.com>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.10]:49977 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906AbaEWJ3Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 05:29:24 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1724C45F@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 23 May 2014 08:29:52 David Laight wrote:
> From: Arnd Bergmann
> > 7c2ce6e60f703 "enic: Add support for adaptive interrupt coalescing"
> > introduced a 64-bit division that causes a link error on all 32-bit
> > machines:
> > 
> > drivers/built-in.o: In function `enic_poll_msix':
> > :(.text+0x54ff00): undefined reference to `__aeabi_uldivmod'
> > 
> > Since we are dividing another 32-bit value and are only interested
> > in the approximate range here, it should always be safe to limit
> > the delta to an u32 value.
> ...
> >  	traffic <<= 3;
> > -	traffic /= delta;
> > +	traffic /= min_t(u32, delta, UINT_MAX);
> 
> I suspect that doesn't have the desired effect.
> I think it is the same as:
> 	traffic /= (u32)delta;

Ah, you are right, sorry for that.

> If you was the correct value for large 'delta' then maybe:
> 	traffic = delta > UINT_MAX ? 0 : traffic / (u32)delta;

That looks better, yes.

	Arnd
