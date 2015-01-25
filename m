From: Jens Kuske <jenskuske-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 0/3] net: allwinner: sun4i-emac: add missing
 SRAM mapping
Date: Sun, 25 Jan 2015 16:49:16 +0100
Message-ID: <1422200959-1717-1-git-send-email-jenskuske@gmail.com>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	Jens Kuske <jenskuske-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Lee Jones <lee.jones-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-sunxi+bncBCC5XIE2SIHBBBFBSSTAKGQEW3VPX3A-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <http://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

Hi all,

The current sun4i-emac kernel driver does not set the needed SRAM mapping.

This hasn't been noticed because normally the bootloader already did this.
But in case the bootloader skips initializing the EMAC, like in U-Boot's
Falcon Mode for example, the kernel driver has to take care of it.

Patch 1-2 add a mfd/syscon for the shared registers responsible for SRAM
mapping. These patches are taken from Chen-Yu Tsai's sunxi-musb tree [1] and
I added a copy of the device-tree nodes to sun4i and sun5i.

Patch 3 adds the code to map SRAM to EMAC using the syscon.

Regards,
Jens

[1] https://github.com/wens/linux/commits/wip/sunxi-musb


Chen-Yu Tsai (2):
  ARM: dts: sunxi: Add syscon node for controlling SRAM mapping
  ARM: sunxi: Add register bit definitions for SRAM mapping syscon

Jens Kuske (1):
  net: allwinner: sun4i-emac: fix emac SRAM mapping

 arch/arm/boot/dts/sun4i-a10.dtsi            |  5 ++++
 arch/arm/boot/dts/sun5i-a10s.dtsi           |  5 ++++
 arch/arm/boot/dts/sun5i-a13.dtsi            |  5 ++++
 arch/arm/boot/dts/sun7i-a20.dtsi            |  5 ++++
 drivers/net/ethernet/allwinner/Kconfig      |  1 +
 drivers/net/ethernet/allwinner/sun4i-emac.c | 18 +++++++++++++
 include/linux/mfd/syscon/sun4i-sc.h         | 42 +++++++++++++++++++++++++++++
 7 files changed, 81 insertions(+)
 create mode 100644 include/linux/mfd/syscon/sun4i-sc.h

-- 
2.2.2
