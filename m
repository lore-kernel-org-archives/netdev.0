From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 00/26] atl1: divide and modernize
Date: Mon, 31 Dec 2007 20:22:27 -0600
Message-ID: <1199154173-4058-1-git-send-email-jacliburn@bellsouth.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost01.isp.att.net ([204.127.217.101]:61218 "EHLO
	fmailhost01.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751726AbYAAC2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 21:28:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[Neglected to cc netdev in the first wave.]

Hello Jeff,

Happy New Year to you and all.

In preparation for a future atl2 driver for the Atheros L2 10/100 chip,
we propose to move the existing atl1 driver to a new directory
(drivers/net/atlx), then split out functions and definitions that both
atl1 and atl2 can share.  The final structure will look like this:

directory or file		status
=======================		==========================
drivers/net/atl1/		deleted
drivers/net/atlx/		new
drivers/net/atlx/atl1.c		atl1-specific functions
drivers/net/atlx/atl1.h		atl1-specific definitions
drivers/net/atlx/atlx.c		atl1-atl2 shared functions
drivers/net/atlx/atlx.h		atl1-atl2 shared definitions

The first two patches submitted in this patchset accomplish the relocation
by movng the atl1 driver -- lock, stock, and barrel -- over to
drivers/net/atlx, then splitting out shareable functions and definitions.
Some transitory hackery will be present until the atl2 merge.  Please
overlook it for now.

The remaining 24 patches bring the atl1 driver up to par with the current
vendor driver version 1.2.40.2.  NAPI support is included and it seems
to work, but it needs to be scrutinized by an experienced eye.  I had a
hard time finding much current NAPI documentation, so I just hacked at
it by looking at the e1000 driver.

Patch 02/26 is too large for LKML, so it's available at:

ftp://ftp.hogchain.net/pub/linux/attansic/atlx

Or, alternatively, the whole shebang can be pulled from:

git://git.hogchain.net/home/jcliburn/netdev-2.6.git atl1-for-jeff


Table of contents:
---
0001-atl1-relocate-atl1-driver-to-drivers-net-atlx.patch
0002-atl1-move-common-functions-to-atlx-files.patch
0003-atl1-fix-broken-TSO.patch
0004-atl1-add-ethtool-register-dump.patch
0005-atl1-print-debug-info-if-rrd-error.patch
0006-atl1-update-initialization-parameters.patch
0007-atl1-clarify-max-rx-frame-size.patch
0008-atl1-additional-DMA-engine-configuration.patch
0009-atl1-refactor-tx-processing.patch
0010-atl1-use-csum_start.patch
0011-atl1-refactor-initialization-and-startup.patch
0012-atl1-refactor-atl1_probe.patch
0013-atl1-refactor-interrupt-handling.patch
0014-atl1-move-stray-defines-to-header-file.patch
0015-atl1-tidy-up-ring-management.patch
0016-atl1-modernize-check-link-function.patch
0017-atl1-update-phy-config-function.patch
0018-atl1-make-function-static.patch
0019-atl1-modernize-down-up-functions.patch
0020-atl1-update-change-mtu.patch
0021-atl1-update-atl1_close.patch
0022-atl1-update-netpoll.patch
0023-atl1-update-shutdown-and-remove-functions.patch
0024-atl1-update-wake-on-lan.patch
0025-atl1-add-NAPI-support.patch
0026-atl1-remove-experimental-tag-and-clean-up-comments.patch


Summary diffstat:
---
 drivers/net/Kconfig             |   18 +-
 drivers/net/Makefile            |    2 +-
 drivers/net/atl1/Makefile       |    2 -
 drivers/net/atl1/atl1.h         |  286 ---
 drivers/net/atl1/atl1_ethtool.c |  505 ------
 drivers/net/atl1/atl1_hw.c      |  720 --------
 drivers/net/atl1/atl1_hw.h      |  946 ----------
 drivers/net/atl1/atl1_main.c    | 2453 --------------------------
 drivers/net/atl1/atl1_param.c   |  203 ---
 drivers/net/atlx/Makefile       |    1 +
 drivers/net/atlx/atl1.c         | 3648 +++++++++++++++++++++++++++++++++++++++
 drivers/net/atlx/atl1.h         |  849 +++++++++
 drivers/net/atlx/atlx.c         |  433 +++++
 drivers/net/atlx/atlx.h         |  533 ++++++
 14 files changed, 5481 insertions(+), 5118 deletions(-)
 delete mode 100644 drivers/net/atl1/Makefile
 delete mode 100644 drivers/net/atl1/atl1.h
 delete mode 100644 drivers/net/atl1/atl1_ethtool.c
 delete mode 100644 drivers/net/atl1/atl1_hw.c
 delete mode 100644 drivers/net/atl1/atl1_hw.h
 delete mode 100644 drivers/net/atl1/atl1_main.c
 delete mode 100644 drivers/net/atl1/atl1_param.c
 create mode 100644 drivers/net/atlx/Makefile
 create mode 100644 drivers/net/atlx/atl1.c
 create mode 100644 drivers/net/atlx/atl1.h
 create mode 100644 drivers/net/atlx/atlx.c
 create mode 100644 drivers/net/atlx/atlx.h

Best regards,
Jay Cliburn

