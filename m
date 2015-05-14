From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 00/11] convert stmmac glue layers into platform drivers
Date: Thu, 14 May 2015 12:10:55 +0200
Message-ID: <1431598266-25736-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-arm-kernel@lists.infradead.org,
	linux-rockchip@lists.infradead.org
To: arnd@arndb.de, peppe.cavallaro@st.com, roger.chen@rock-chips.com,
	wens@csie.org, srinivas.kandagatla@st.com,
	dinguyen@opensource.altera.com, b.galvani@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:33369 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932490AbbENKLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 06:11:40 -0400
Received: by layy10 with SMTP id y10so60494600lay.0
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 03:11:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set aims to convert the current dwmac glue layers into
proper platform drivers as request by Arnd[1]. These changes start
from patch 3 and onwards.

Overview:
Platform driver functions like probe and remove are exported from
the stmmac platform and then used in subsequent glue later
conversions. The conversion involes adding the platform driver
boiler plate code and adding it to the build system. The last patch
removes the driver from the stmmac platform code thus making it into
a library for common platform driver functions.

The two first patches adds glue layer for my platform. I chose to
first add old style glue layer and then convert it. The churn this
creates is just 3 lines.

I would be very nice if people could test this patch set on their
respective platform. My testing has been limited to compiling and
testing on my (LPC18xx) platform. Thanks!

Next I will look into cleaning up the stmmac platform code.

[1] http://marc.info/?l=linux-arm-kernel&m=143059524606459&w=2

Joachim Eastwood (11):
  stmmac: add dwmac glue for NXP 18xx/43xx family
  doc: dt: add documentation for nxp,lpc1850-dwmac
  stmmac: prepare stmmac platform to support stand alone drivers
  stmmac: add a generic dwmac driver
  stmmac: convert dwmac-lpc18xx to a platform driver
  stmmac: convert dwmac-meson to platform driver
  stmmac: convert dwmac-rk to platform driver
  stmmac: convert dwmac-socfpga to platform driver
  stmmac: convert dwmac-sti to platform driver
  stmmac: convert dwmac-sunxi to platform driver
  stmmac: drop driver from stmmac platform code

 .../devicetree/bindings/net/nxp,lpc1850-dwmac.txt  | 20 +++++
 drivers/net/ethernet/stmicro/stmmac/Kconfig        | 76 +++++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/Makefile       | 13 ++-
 .../net/ethernet/stmicro/stmmac/dwmac-generic.c    | 41 +++++++++
 .../net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c    | 99 ++++++++++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c  | 24 +++++-
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c     | 27 +++++-
 .../net/ethernet/stmicro/stmmac/dwmac-socfpga.c    | 21 ++++-
 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c    | 29 ++++++-
 drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c  | 25 +++++-
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 49 ++---------
 .../net/ethernet/stmicro/stmmac/stmmac_platform.h  |  9 +-
 12 files changed, 378 insertions(+), 55 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/nxp,lpc1850-dwmac.txt
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c

-- 
1.8.0
