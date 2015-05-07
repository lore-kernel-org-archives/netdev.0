From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH RFC 0/2] stmmac: stand alone platform drivers
Date: Thu,  7 May 2015 20:19:23 +0200
Message-ID: <1431022765-30715-1-git-send-email-manabian@gmail.com>
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	davem@davemloft.net, linux-arm-kernel@lists.infradead.org,
	Joachim Eastwood <manabian@gmail.com>
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:35177 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752232AbbEGSTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 14:19:32 -0400
Received: by labbd9 with SMTP id bd9so36816868lab.2
        for <netdev@vger.kernel.org>; Thu, 07 May 2015 11:19:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arnd,

I ran into some issue using a separate platform driver[1] for lpc1850-dwmac.

My dts files looks like this.
mac: ethernet@40010000 {
	compatible = "nxp,lpc1850-dwmac", "snps,dwmac-3.611", "snps,dwmac";
	...
}

On boot the generic driver in stmmac_platform.c would grab the
device, matching on one of generic compat strings and thus blocking
the lpc1850-dwmac driver.

By changing the build order in the Makefile (see patch 1) I managed
to get it working, but I am not sure that is a good solution(?).

Another fix would be to remove the generic compat strings from the
match table in stmmac_platform but there are some dts-files that
only have these compat strings.
See abilis_tb10x.dtsi and exynos5440.dtsi.

I could also remove the generic compat strings from my dts file but
I am not sure that is good solution either. If more glue is
converted this would then be need in those dts files also.


Any advice on how to handle this situation?


[1] http://marc.info/?l=linux-arm-kernel&m=143076781409270&w=2

Joachim Eastwood (2):
  stmac: support standalone platform drivers
  stmac: add dwmac glue for NXP 18xx/43xx family

 drivers/net/ethernet/stmicro/stmmac/Makefile       | 11 ++-
 .../net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c    | 98 ++++++++++++++++++++++
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 14 ++--
 .../net/ethernet/stmicro/stmmac/stmmac_platform.h  |  4 +
 4 files changed, 120 insertions(+), 7 deletions(-)
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c

-- 
1.8.0
