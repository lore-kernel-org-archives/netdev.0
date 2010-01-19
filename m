From: Anatolij Gustschin <agust-ynQEQJNshbs@public.gmane.org>
Subject: [PATCH 0/11] Update support for MPC512x
Date: Tue, 19 Jan 2010 21:24:02 +0100
Message-ID: <1263932653-3634-1-git-send-email-agust@denx.de>
Cc: dzu-ynQEQJNshbs@public.gmane.org, wd-ynQEQJNshbs@public.gmane.org, Anatolij Gustschin <agust-ynQEQJNshbs@public.gmane.org>,
	Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>,
	John Rigby <jcrigby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<rtc-linux-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>, <linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The following patch series brings support for the Freescale MPC512x
processsors up to date:

[PATCH 01/11] fs_enet: Add support for MPC512x to fs_enet driver
[PATCH 02/11] fs_enet: Add FEC TX Alignment workaround for MPC5121
[PATCH 03/11] powerpc/mpc5121: Add machine restart support
[PATCH 04/11] i2c-mpc: Add MPC5121 I2C bus support
[PATCH 05/11] rtc: Add MPC5121 Real time clock driver
[PATCH 06/11] mtd: Add NAND Flash Controller driver
[PATCH 07/11] dma: Add MPC512x DMA driver
[PATCH 08/11] powerpc/mpc5121: add USB host support
[PATCH 09/11] powerpc/mpc512x: shared DIU framebuffer support
[PATCH 10/11] powerpc/mpc5121: update mpc5121ads DTS
[PATCH 11/11] powerpc/mpc5121: Add default config for MPC5121ADS

The patches are based on v2.6.33-rc4 and cover the following
items:

- platform, DTS
- DMA
- FEC Ethernet
- UART (without h/w flow control)
- I2C
- NAND
- RTC

The code has been tested on the Freescale/STX "MPC5121ADS" board
(board rev. 4) with a MPC5121e Rev. 2. No attempt was made to provide
backward compatibility to older silicon revisions or older revisions
of the board.

Cc: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Cc: John Rigby <jcrigby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: <linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: <rtc-linux-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Cc: <linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Cc: <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
---
 Documentation/powerpc/dts-bindings/fsl/usb.txt |    8 +
 arch/powerpc/boot/dts/mpc5121ads.dts           |   35 +-
 arch/powerpc/configs/512x/mpc5121ads_defconfig | 1662 ++++++++++++++++++++++++
 arch/powerpc/include/asm/mpc5xxx.h             |   14 +-
 arch/powerpc/platforms/512x/Kconfig            |    6 +
 arch/powerpc/platforms/512x/Makefile           |    2 +-
 arch/powerpc/platforms/512x/mpc5121_ads.c      |    9 +
 arch/powerpc/platforms/512x/mpc5121_generic.c  |   13 +
 arch/powerpc/platforms/512x/mpc5121_usb.c      |  117 ++
 arch/powerpc/platforms/512x/mpc512x.h          |    5 +
 arch/powerpc/platforms/512x/mpc512x_shared.c   |  320 +++++-
 arch/powerpc/sysdev/fsl_soc.c                  |   10 +
 arch/powerpc/sysdev/fsl_soc.h                  |   10 +
 drivers/dma/Kconfig                            |    7 +
 drivers/dma/Makefile                           |    1 +
 drivers/dma/mpc512x_dma.c                      |  636 +++++++++
 drivers/dma/mpc512x_dma.h                      |  192 +++
 drivers/i2c/busses/Kconfig                     |    9 +-
 drivers/i2c/busses/i2c-mpc.c                   |   23 +
 drivers/mtd/nand/Kconfig                       |    7 +
 drivers/mtd/nand/Makefile                      |    1 +
 drivers/mtd/nand/mpc5121_nfc.c                 |  916 +++++++++++++
 drivers/net/fs_enet/Kconfig                    |   10 +-
 drivers/net/fs_enet/fs_enet-main.c             |   43 +
 drivers/net/fs_enet/fs_enet.h                  |   40 +-
 drivers/net/fs_enet/mac-fec.c                  |  132 ++-
 drivers/net/fs_enet/mii-fec.c                  |   55 +-
 drivers/net/fs_enet/mpc5121_fec.h              |   64 +
 drivers/net/fs_enet/mpc8xx_fec.h               |   37 +
 drivers/rtc/Kconfig                            |   10 +
 drivers/rtc/Makefile                           |    1 +
 drivers/rtc/rtc-mpc5121.c                      |  408 ++++++
 drivers/usb/host/ehci-fsl.c                    |  213 +++-
 drivers/usb/host/ehci-fsl.h                    |   19 +-
 drivers/usb/host/ehci-mem.c                    |    2 +-
 drivers/video/fsl-diu-fb.c                     |   40 +-
 drivers/video/fsl-diu-fb.h                     |  223 ----
 include/linux/fsl-diu-fb.h                     |  223 ++++
 include/linux/fsl_devices.h                    |   10 +
 39 files changed, 5193 insertions(+), 340 deletions(-)
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
