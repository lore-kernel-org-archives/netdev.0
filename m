From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2] net: fec: make driver endian-safe
Date: Sun, 24 Jan 2016 17:49:54 +0100
Message-ID: <1637940.UNKGUmXJxm@wuerfel>
References: <1453650757-27459-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, Greg Ungerer <gerg@uclinux.org>,
	Lucas Stach <l.stach@pengutronix.de>,
	Fugang Duan <B38611@freescale.com>,
	Shawn Guo <shawnguo@kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.133]:57028 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751461AbcAXQuO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jan 2016 11:50:14 -0500
In-Reply-To: <1453650757-27459-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 24 January 2016 16:52:37 Johannes Berg wrote:
> It's not clear that the ifdef there really is correct and shouldn't
> just be #ifdef CONFIG_ARM, but I also can't test on anything but the
> i.MX6 HummingBoard where this gets it working with a BE kernel.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

I'd argue that the "(CONFIG_ARCH_MXC) || defined(CONFIG_SOC_IMX28)"
is definitely wrong, because if we ever get another ARM platform
that uses this driver, it may or may not work depending on whether
the ARCH_MXC is also set, and that is not a helpful behavior.

Better make it simply CONFIG_ARM to keep the behavior independent
of config options. It won't change anything for now but any future
platform will probably work independent of configuration or would
require a bugfix at all.

	Arnd
