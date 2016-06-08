From: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>
Subject: [PATCH v6 0/2] Add CAN FD driver support to r8a7795 SoC
Date: Wed,  8 Jun 2016 07:38:14 +0100
Message-ID: <1465367896-60207-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
References: <SG2PR06MB1038056F44EFBCB51674B832C35D0@SG2PR06MB1038.apcprd06.prod.outlook.com>
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	chris.paterson2@renesas.com, horms@verge.net.au,
	magnus.damm@gmail.com, ulrich.hecht@gmail.com,
	Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>
To: mkl@pengutronix.de, wg@grandegger.com, socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor2.renesas.com ([210.160.252.172]:36529 "EHLO
	relmlie1.idc.renesas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755791AbcFHHF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 03:05:59 -0400
In-Reply-To: <SG2PR06MB1038056F44EFBCB51674B832C35D0@SG2PR06MB1038.apcprd06.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

   This patch is based on can-next latest tag "linux-can-next-for-4.7-20160509"

Changes since v5:
	* Addressed Ulrich's concerns on register, bits naming convention
	* Rebased to latest tag (linux-can-next-for-4.7-20160509)

Changes since v4:
	* Rebased to latest can-next/testing branch
	* Addressed Marc K review comments on v2 patch
	* Use clk_get_rate() to find ext clock availability. Refer thread
	(https://lkml.org/lkml/2016/4/8/203)

Changes since v3:
	* Split v3 patch into two (Marc K)
	  (1) Introduce rcar_canfd.c driver in drivers/net/can/rcar dir
	  (2) Move rcar_can.c driver to new drivers/net/can/rcar dir
	* Added Acked-by Rob H for the bindings
	* Added comments on CAN FD only mode in driver & Kconfig (Oliver H)

Changes since v2:
	* Rebased to latest tag (linux-can-next-for-4.6-20160310)
	* Cleaned up leftover debugfs code (Thanks Oliver H)
	* Revised devicetree documentation text (as suggested by Rob H)
	  (https://www.mail-archive.com/linux-renesas-soc@vger.kernel.org/msg01597.html)
	* Used new can subsystem api to set static configuration & removed check in rcar_canfd_start (as suggested by Oliver H)
	  (Refer: http://comments.gmane.org/gmane.linux.can/9126 &
	   https://www.mail-archive.com/linux-renesas-soc@vger.kernel.org/msg01867.html)
	* Clubbed Renesas controller drivers to driver/net/can/rcar dir (as suggested by Oliver H)
	* Updated commit message

Changes since v1:
	* Removed testmodes & debugfs code (suggested by Oliver H)
	* Fixed tx path race issue by introducing lock (suggested by Marc K)
	* Removed __maybe_unused attribute of rcar_canfd_of_table


Ramesh Shanmugasundaram (2):
  can: rcar_canfd: Add Renesas R-Car CAN FD driver
  can: rcar_can: Move Renesas CAN driver to rcar dir

 .../devicetree/bindings/net/can/rcar_canfd.txt     |   89 +
 drivers/net/can/Kconfig                            |   11 +-
 drivers/net/can/Makefile                           |    2 +-
 drivers/net/can/rcar/Kconfig                       |   21 +
 drivers/net/can/rcar/Makefile                      |    6 +
 drivers/net/can/{ => rcar}/rcar_can.c              |    0
 drivers/net/can/rcar/rcar_canfd.c                  | 1695 ++++++++++++++++++++
 7 files changed, 1813 insertions(+), 11 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/can/rcar_canfd.txt
 create mode 100644 drivers/net/can/rcar/Kconfig
 create mode 100644 drivers/net/can/rcar/Makefile
 rename drivers/net/can/{ => rcar}/rcar_can.c (100%)
 create mode 100644 drivers/net/can/rcar/rcar_canfd.c

-- 
1.9.1
