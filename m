From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH RFC 0/7] support the cpts found on am335x devices
Date: Thu, 11 Oct 2012 22:27:15 +0200
Message-ID: <cover.1349985570.git.richardcochran@gmail.com>
Cc: <linux-arm-kernel@lists.infradead.org>,
	David Miller <davem@davemloft.net>,
	Cyril Chemparathy <cyril@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Sriramakrishnan A G <srk@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:57395 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752178Ab2JKU1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 16:27:34 -0400
Received: by mail-wi0-f178.google.com with SMTP id hr7so2869452wib.1
        for <netdev@vger.kernel.org>; Thu, 11 Oct 2012 13:27:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series, based on today's mainline master 12250d8, is a RFC
adding support for the Common Platform Time Sync (CPTS) found on the
popular BeagleBone. The code enables hardware time stamping and a PTP
Hardware Clock.

Due to DT problems with the most current CPSW driver, this work has
been compiled and booted, but not tested. However, I have tested work
similar to this, based on the AM335XPSP_04.06.00.08 branch in TI's
arago repo, and found it to work well.

There are two open issue with this driver, which will hopefully soon
be resolved.

1. ATM it is not possible to adjust the clock frequency. I heard a
   rumor that the fractional multipliers on the am335x do not work
   when changed, but I have not yet verified this myself. Even if it
   turns out to be true, still the driver will be useful for 802.1AS
   applications, since they will typically use a free running clock.

2. Time stamping only works on UDP packets. Although Layer 2 is
   supposed to work according to the TRM, I have not yet figured out
   how. The UDP only works when setting an undocumented bit, so maybe
   someone from TI can fill me in on this.

Thanks,
Richard


Richard Cochran (7):
  cpsw: rename register banks to match the reference manual
  cpsw: add missing fields to the CPSW_SS register bank.
  cpsw: correct the CPSW_PORT register bank declaration
  cpsw: add a common header file for regsiter declarations
  cpts: introduce time stamping code and a PTP hardware clock.
  cpsw: add a DT field for the cpts offset
  cpsw: use the time stamping capabilities of the cpts

 Documentation/devicetree/bindings/net/cpsw.txt |   11 +-
 drivers/net/ethernet/ti/Kconfig                |    8 +
 drivers/net/ethernet/ti/Makefile               |    2 +-
 drivers/net/ethernet/ti/cpsw.c                 |   80 ++++-
 drivers/net/ethernet/ti/cpsw_reg.h             |   81 ++++
 drivers/net/ethernet/ti/cpts.c                 |  469 ++++++++++++++++++++++++
 drivers/net/ethernet/ti/cpts.h                 |  148 ++++++++
 include/linux/platform_data/cpsw.h             |    1 +
 8 files changed, 785 insertions(+), 15 deletions(-)
 create mode 100644 drivers/net/ethernet/ti/cpsw_reg.h
 create mode 100644 drivers/net/ethernet/ti/cpts.c
 create mode 100644 drivers/net/ethernet/ti/cpts.h

-- 
1.7.2.5
