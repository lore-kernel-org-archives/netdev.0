From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 1/3] net: phy: prevent linking breakage
Date: Tue, 28 May 2013 13:09:20 -0700 (PDT)
Message-ID: <20130528.130920.1604291112518863799.davem@davemloft.net>
References: <1369741403-25315-1-git-send-email-alexandre.belloni@free-electrons.com>
	<1369741403-25315-2-git-send-email-alexandre.belloni@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux@arm.linux.org.uk,
	shawn.guo@linaro.org, kernel@pengutronix.de
To: alexandre.belloni@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369741403-25315-2-git-send-email-alexandre.belloni@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Date: Tue, 28 May 2013 13:43:21 +0200

> phy_register_fixup{,_for_uid,_for_id} are called from arch/, quite
> often, there is no protection to check whether CONFIG_PHYLIB=y which is
> the only case where this would work. Having phylib as a module or not
> compiled at all will result in that kind of linking failure:
> 
> arch/arm/mach-at91/built-in.o: In function `ksz9021rn_phy_fixup':
> :(.text+0x1174): undefined reference to `mdiobus_write'
> :(.text+0x1188): undefined reference to `mdiobus_write'
> :(.text+0x119c): undefined reference to `mdiobus_write'
> :(.text+0x11b0): undefined reference to `mdiobus_write'
> arch/arm/mach-at91/built-in.o: In function `sama5_dt_device_init':
> :(.init.text+0x1e34): undefined reference to `phy_register_fixup_for_uid'
> 
> Signed-off-by: Alexandre Belloni <alexandre.belloni@free-electrons.com>

This is the wrong way to go about this.

If the arch code absolutely requires CONFIG_PHYLIB=y then express that
dependency in the arch Kconfig.  The arch code in question should not
be compiled at all if CONFIG_PHYLIB has an incompatible setting.
