From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH] r8169: RxConfig hack for the 8168evl.
Date: Mon, 25 Jun 2012 11:31:50 +0800
Message-ID: <DB5F775AE8124DDDAE4E1501A78AF7A3@realtek.com.tw>
References: <20120620220918.GA2785@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <thomas.pi@arcor.de>
To: 'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:58596 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752654Ab2FYDcH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2012 23:32:07 -0400
In-Reply-To: <20120620220918.GA2785@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, 

> - the patch sets the RX_MULTI_EN bit. If the 8168c doc is any guide,
>   the chipset now fetches several Rx descriptors at a time.
> - long ago the driver ignored the RX_MULTI_EN bit.
>   e542a2269f232d61270ceddd42b73a4348dee2bb changed the RxConfig
>   settings. Whatever the problem it's now labeled a regression.

The definition of the IO 0x44 bit 14 is opposite for new chips.
For 8111C, 0 means fetching one Rx descriptor, and 1 means fetching
multi-descriptors.
For 8111D and the later chips, 0 means fetching multi-descriptors, and 1 means
fetching one Rx descriptor.

However, I have no idea about why it influences the issue.

> - Realtek's own driver can identify two different 8168evl devices
>   (CFG_METHOD_16 and CFG_METHOD_17) where the r8169 driver only
>   sees one. It sucks.

The CFG_METHOD_16 is the internal test chip. We don't have mass production for
it. Even it could be removed from driver. I don't think the kernel have to
support it.
 
Best Regards,
Hayes
