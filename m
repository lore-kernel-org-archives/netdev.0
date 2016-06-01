From: Lucas Stach <l.stach-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH 0/2] Software workaround for i.MX6Q/DL ERR006687
Date: Wed,  1 Jun 2016 17:29:41 +0200
Message-ID: <1464794983-31484-1-git-send-email-l.stach@pengutronix.de>
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org,
	patchwork-lst-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org
To: Shawn Guo <shawnguo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Fugang Duan <fugang.duan-3arQi8VN3Tc@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi all,

this short series adds a software workaround for the i.MX6Q/DL erratum
ERR006687, where the FEC IRQ is unable to wake the CPU from deep idle
states.

Until now the only two options to avoid triggering the erratum was to
apply the hardware workround as described in the errata sheet, or to
disable CPU_IDLE in the kernel configuration. As the hardware workaround
isn't applicable on all boards, this left a fair amount of boards
suffering from the erratum, as CPU_IDLE is enabled in the i.MX6 and
multi-v7 defconfig.

The software workaround implemented here is to simply disable the deeper
CPU idle states on boards which don't have the HW workaround if the FEC
is active. Aside from enabling us to run a single kernel config across
all boards, this has the additional benefit that boards without the HW
workaround are still able to use the deeper idle states if the network
interface isn't active.

I would prefer if this series gets merged through the imx achitecture
tree with acks for the FEC changes from the network people.

Regards,
Lucas

Lucas Stach (2):
  ARM: imx6: disable deeper idle states when FEC is active w/o HW
    workaround
  ARM: dts: imx6: tag boards that have the HW workaround for ERR006687

 Documentation/devicetree/bindings/net/fsl-fec.txt |  3 +++
 arch/arm/boot/dts/imx6dl-riotboard.dts            |  1 +
 arch/arm/boot/dts/imx6q-arm2.dts                  |  1 +
 arch/arm/boot/dts/imx6qdl-nit6xlite.dtsi          |  1 +
 arch/arm/boot/dts/imx6qdl-nitrogen6_max.dtsi      |  1 +
 arch/arm/boot/dts/imx6qdl-nitrogen6x.dtsi         |  1 +
 arch/arm/boot/dts/imx6qdl-sabreauto.dtsi          |  1 +
 arch/arm/boot/dts/imx6qdl-sabrelite.dtsi          |  1 +
 arch/arm/boot/dts/imx6qdl-wandboard.dtsi          |  1 +
 arch/arm/mach-imx/cpuidle-imx6q.c                 | 16 +++++++++++++++
 drivers/net/ethernet/freescale/fec.h              |  2 ++
 drivers/net/ethernet/freescale/fec_main.c         | 12 +++++++++++
 include/soc/imx/cpuidle.h                         | 25 +++++++++++++++++++++++
 13 files changed, 66 insertions(+)
 create mode 100644 include/soc/imx/cpuidle.h

-- 
2.8.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
