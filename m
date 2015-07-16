From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 0/8] stmmac clean up for 4.3 part1
Date: Fri, 17 Jul 2015 00:26:04 +0200
Message-ID: <1437085572-11371-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org
To: peppe.cavallaro@st.com, davem@davemloft.net, arnd@arndb.de,
	b.galvani@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:35879 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751528AbbGPW0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 18:26:34 -0400
Received: by lagw2 with SMTP id w2so51607503lag.3
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 15:26:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi everyone,

This patch set continues the conversion of the dwmac glue layers
to more proper platform drivers. The first part of the patch set
cleans up stmmac_platform a bit. Refactors code from the common
probe function and exports two functions that will be used in
the dwmac-* drivers.

Second part converts two simple dwmac-* drivers to have their
own probe function and use the exported functions. This brings
us closer to point where stmmac_platform is only a library of
common functions for the dwmac-* drivers to use.

The plan next is:
 * add probe functions to the rest of the dwmac-* drivers
 * move probe function in stmmac_platform to dwmac-generic
 * remove struct stmmac_of_data and let those drivers
   that actually need match data handle it themselves
 * clean up include/linux/stmmac.h

Note that this patch set has only been tested on lpc18xx so
testing on other platforms is greatly appreciated.

Previous parts can be found here:
http://www.spinics.net/lists/netdev/msg328997.html
http://www.spinics.net/lists/netdev/msg329932.html

Joachim Eastwood (8):
  stmmac: use of_device_get_match_data to retrieve of match data
  stmmac: clean up platform/of_match data retrieval
  stmmac: introduce stmmac_get_platform_resources()
  stmmac: make stmmac_probe_config_dt return the platform data struct
  stmmac: export probe_config_dt() and get_platform_resources()
  stmmac: add proper probe function to dwmac-lpc18xx
  stmmac: add proper probe function to dwmac-meson
  stmmac: drop custom_* fields from plat_stmmacenet_data

 Documentation/networking/stmmac.txt                |   4 -
 .../net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c    |  59 ++++-----
 drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c  |  31 +++--
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 136 ++++++++++++---------
 .../net/ethernet/stmicro/stmmac/stmmac_platform.h  |   8 ++
 include/linux/stmmac.h                             |   2 -
 6 files changed, 126 insertions(+), 114 deletions(-)

-- 
1.8.0
