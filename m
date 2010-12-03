From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/4] ath: logging message conversion
Date: Thu,  2 Dec 2010 19:12:34 -0800
Message-ID: <cover.1291333543.git.joe@perches.com>
References: <20101202190239.GE7399@tux>
Cc: Peter Stuge <peter@stuge.se>, Felix Fietkau <nbd@openwrt.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Luis R. Rodriguez" <lrodriguez@atheros.com>,
	linux-wireless@vger.kernel.org, ath5k-devel@lists.ath5k.org,
	ath9k-devel@lists.ath9k.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101202190239.GE7399@tux>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ath_print is misleading as it's only used with CONFIG_ATH_DEBUG.

Add and use the more normal <subsystem>_printk and <subsystem>_<level>
printk equivalents. (ath_printk and ath_<level>)

Fix various defects in the current uses of ath_print formats
and arguments: Unnecessary casts, missing newlines, multiple
prints, and 1 loop which can exceed array bounds.

Bundled and integrated the individual patches into a single patch series.

Joe Perches (4):
  ath: Add and use ath_printk and ath_<level>
  ath: Convert ath_print(.., ATH_DBG_FATAL to ath_err
  ath: Convert ath_print to ath_dbg
  ath: Fix ath_dbg access beyond array bound

 drivers/net/wireless/ath/ath.h                  |  103 +++++++++++
 drivers/net/wireless/ath/ath5k/base.c           |    1 -
 drivers/net/wireless/ath/ath5k/debug.c          |    1 -
 drivers/net/wireless/ath/ath9k/ahb.c            |    7 +-
 drivers/net/wireless/ath/ath9k/ani.c            |   97 +++++------
 drivers/net/wireless/ath/ath9k/ar5008_phy.c     |  199 +++++++++------------
 drivers/net/wireless/ath/ath9k/ar9002_calib.c   |  220 +++++++++++------------
 drivers/net/wireless/ath/ath9k/ar9002_hw.c      |    6 +-
 drivers/net/wireless/ath/ath9k/ar9002_mac.c     |   20 +-
 drivers/net/wireless/ath/ath9k/ar9003_calib.c   |  217 +++++++++++-----------
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c  |  174 ++++++++-----------
 drivers/net/wireless/ath/ath9k/ar9003_mac.c     |   16 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c     |  205 ++++++++++-----------
 drivers/net/wireless/ath/ath9k/beacon.c         |   79 ++++-----
 drivers/net/wireless/ath/ath9k/calib.c          |   59 +++---
 drivers/net/wireless/ath/ath9k/common.c         |    4 +-
 drivers/net/wireless/ath/ath9k/common.h         |    1 -
 drivers/net/wireless/ath/ath9k/eeprom.c         |    4 +-
 drivers/net/wireless/ath/ath9k/eeprom_4k.c      |   72 ++++----
 drivers/net/wireless/ath/ath9k/eeprom_9287.c    |   39 ++---
 drivers/net/wireless/ath/ath9k/eeprom_def.c     |   67 ++++----
 drivers/net/wireless/ath/ath9k/gpio.c           |   20 +-
 drivers/net/wireless/ath/ath9k/htc_drv_beacon.c |   24 ++--
 drivers/net/wireless/ath/ath9k/htc_drv_gpio.c   |   15 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c   |   63 +++----
 drivers/net/wireless/ath/ath9k/htc_drv_main.c   |  192 ++++++++++----------
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c   |   33 ++--
 drivers/net/wireless/ath/ath9k/hw.c             |  161 ++++++++---------
 drivers/net/wireless/ath/ath9k/hw.h             |    1 -
 drivers/net/wireless/ath/ath9k/init.c           |   28 ++--
 drivers/net/wireless/ath/ath9k/mac.c            |  117 ++++++-------
 drivers/net/wireless/ath/ath9k/main.c           |  185 +++++++++----------
 drivers/net/wireless/ath/ath9k/pci.c            |    7 +-
 drivers/net/wireless/ath/ath9k/rc.c             |   18 +-
 drivers/net/wireless/ath/ath9k/recv.c           |   48 +++---
 drivers/net/wireless/ath/ath9k/virtual.c        |    7 +-
 drivers/net/wireless/ath/ath9k/wmi.c            |   12 +-
 drivers/net/wireless/ath/ath9k/xmit.c           |   84 ++++-----
 drivers/net/wireless/ath/debug.c                |   20 --
 drivers/net/wireless/ath/debug.h                |   92 ----------
 drivers/net/wireless/ath/key.c                  |   28 ++--
 drivers/net/wireless/ath/main.c                 |   20 ++
 42 files changed, 1306 insertions(+), 1460 deletions(-)
 delete mode 100644 drivers/net/wireless/ath/debug.h

-- 
1.7.3.2.245.g03276.dirty
