From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH RFC 0/2] stmmac: stand alone platform drivers
Date: Tue, 12 May 2015 21:49:04 +0200
Message-ID: <5948526.xNXlKiLpxq@wuerfel>
References: <1431022765-30715-1-git-send-email-manabian@gmail.com> <5987007.lq0DjS0tE0@wuerfel> <CAGhQ9Vx0DQf-HcqEiohFLrBJPBe5qYjLgXiH3qGx85fAruh8UQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Joachim Eastwood <manabian@gmail.com>,
	"peppe.cavallaro" <peppe.cavallaro@st.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.24]:57789 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751174AbbELTtj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 15:49:39 -0400
In-Reply-To: <CAGhQ9Vx0DQf-HcqEiohFLrBJPBe5qYjLgXiH3qGx85fAruh8UQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 12 May 2015 19:20:45 Joachim Eastwood wrote:
> 
> I have now created a generic dt dwmac driver which contain all compat
> strings that doesn't have any match data. As long as this driver is
> linked last this works for my built-in drivers configuration. I am not
> able to test using modules because of my very limited rootfs. This is
> a Cortex-M system after all.
> 
> I also converted all the other DT dwmac drivers and the entire patch
> set can be found on:
> https://github.com/manabian/linux-lpc
> 
> After I have done some more cleanups and added proper commit messages
> I will put them on netdev again.
> 
> 

Yes, this looks really nice (with the cleanup bits that are obviously
missing applied), thanks a lot!

We should probably try to keep existing defconfig files working,
which could be done e.g. like

 config DWMAC_ROCKCHIP
	tristate "Rockchip dwmac support"
+	default ARCH_ROCKCHIP
	depends on OF
	select MFD_SYSCON

so that any configuration that currently has ARCH_ROCKCHIP and DW_MAC
enabled ends up with DWMAC_ROCKCHIP enabled as well.

	Arnd
