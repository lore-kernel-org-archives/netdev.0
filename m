From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH] r8169: RxConfig hack for the 8168evl.
Date: Wed, 27 Jun 2012 10:43:03 +0800
Message-ID: <6363EB75E2B3491A9D2A47E801341EBE@realtek.com.tw>
References: <20120620220918.GA2785@electric-eye.fr.zoreil.com> <DB5F775AE8124DDDAE4E1501A78AF7A3@realtek.com.tw> <20120626092251.GA1854@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <thomas.pi@arcor.de>
To: 'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:45154 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755802Ab2F0CnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 22:43:17 -0400
In-Reply-To: <20120626092251.GA1854@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Francois Romieu [mailto:romieu@fr.zoreil.com] 
[...]
> > The definition of the IO 0x44 bit 14 is opposite for new chips.
> > For 8111C, 0 means fetching one Rx descriptor, and 1 means fetching
> > multi-descriptors.
> > For 8111D and the later chips, 0 means fetching 
> multi-descriptors, and 1 means
> > fetching one Rx descriptor.
> 
> Ok. Is there much point fetching one Rx descriptor versus several ?

I just know fetching several Rx descriptor has better performance if the
decsriptors are enough. However, I have no idea about how the hardware
implements it.

> 
> [...]
> > The CFG_METHOD_16 is the internal test chip. We don't have 
> mass production for
> > it. Even it could be removed from driver. I don't think the 
> kernel have to
> > support it.
> 
> Ok.
> 
> There seem to be a few differences for the CFG_METHOD_16 
> chipset between
> the kernel driver and Realtek's own. I have noticed the points below.
> Should some of those be included ?

I think you should reference the CFG_METHOD_17, not CFG_METHOD_16.

[...] 
> - 0x7cf00000 / 0x2c900000 is a Realtek internal, test-only chipset
Should be 0x7cf00000 / 0x2c800000

[...] 
> rtl8169_get_mac_version(struct rtl8169_private *tp,
>  		{ 0x7cf00000, 0x48000000,	RTL_GIGA_MAC_VER_35 },
>  
>  		/* 8168E family. */
> -		{ 0x7c800000, 0x2c800000,	RTL_GIGA_MAC_VER_34 },
> +		{ 0x7cf00000, 0x2c800000,	RTL_GIGA_MAC_VER_34 },

Should be	{ 0x7cf00000, 0x2c900000,	RTL_GIGA_MAC_VER_34 },

[...] 
> @@ -4797,6 +4826,9 @@ static void rtl_hw_start_8168e_2(struct 
> rtl8169_private *tp)
>  
>  	RTL_W8(MaxTxPacketSize, EarlySize);
>  
> +	RTL_W8(0xf2, (RTL_R8(0xf2) & ~0x02) | 0x05);

Please remove this line. We verify it would case kernel panic.

[...] 

 
Best Regards,
Hayes
