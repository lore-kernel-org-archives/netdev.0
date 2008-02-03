From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 00/10] atl1: move to atlx and update for 2.6.25
Date: Sat, 2 Feb 2008 19:52:20 -0600
Message-ID: <20080202195220.1d699020@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Chris Snook <csnook@redhat.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost02.isp.att.net ([204.127.217.102]:41567 "EHLO
	fmailhost02.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935836AbYBCBwX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Feb 2008 20:52:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for a future atl2 driver for the Atheros L2 10/100 chip,
we propose to move the existing atl1 driver to a new directory
(drivers/net/atlx), then split out functions and definitions that both
atl1 and atl2 can share.  The final structure will look like this:

drivers/net/atl1                deleted
drivers/net/atlx                new
drivers/net/atlx/atl1.c         atl1-specific functions
drivers/net/atlx/atl1.h         atl1-specific definitions
drivers/net/atlx/atlx.c         atl1-atl2 shared functions
drivers/net/atlx/atlx.h         atl1-atl2 shared definitions

The first two patches submitted in this patchset accomplish the
relocation by moving the atl1 driver over to drivers/net/atlx, then
splitting out shareable functions and definitions.  Some transitory
hackery will be present until the atl2 merge.  Please overlook it for
now.

The remaining 8 patches provide some cleanup and minor functionality
changes, the most important of which is a fix to our long-broken TSO
capability.

The "conform to vendor driver" patches submitted on 31 December 2007
have been dropped.

Table of contents:
---
0001-atl1-relocate-atl1-driver-to-drivers-net-atlx.patch
0002-atl1-move-common-functions-to-atlx-files.patch
0003-atl1-fix-broken-TSO.patch
0004-atl1-add-ethtool-register-dump.patch
0005-atl1-simplify-tx-packet-descriptor.patch
0006-atl1-use-csum_start.patch
0007-atl1-use-netif_msg.patch
0008-atl1-print-debug-info-if-rrd-error.patch
0009-atl1-make-functions-static.patch
0010-atl1-reduce-forward-declarations.patch


Summary diffstat:
---
 drivers/net/Makefile                          |    2 +-
 drivers/net/atl1/Makefile                     |    2 -
 drivers/net/atl1/atl1.h                       |  286 ----
 drivers/net/atl1/atl1_ethtool.c               |  505 ------
 drivers/net/atl1/atl1_hw.c                    |  720 ---------
 drivers/net/atl1/atl1_hw.h                    |  946 -----------
 drivers/net/atl1/atl1_param.c                 |  203 ---
 drivers/net/atlx/Makefile                     |    1 +
 drivers/net/{atl1/atl1_main.c => atlx/atl1.c} | 2118
+++++++++++++++++++------ drivers/net/atlx/atl1.h
|  796 ++++++++++ drivers/net/atlx/atlx.c                       |  433
+++++ drivers/net/atlx/atlx.h                       |  506 ++++++
 12 files changed, 3352 insertions(+), 3166 deletions(-)
 delete mode 100644 drivers/net/atl1/Makefile
 delete mode 100644 drivers/net/atl1/atl1.h
 delete mode 100644 drivers/net/atl1/atl1_ethtool.c
 delete mode 100644 drivers/net/atl1/atl1_hw.c
 delete mode 100644 drivers/net/atl1/atl1_hw.h
 delete mode 100644 drivers/net/atl1/atl1_param.c
 create mode 100644 drivers/net/atlx/Makefile
 rename drivers/net/{atl1/atl1_main.c => atlx/atl1.c} (57%)
 create mode 100644 drivers/net/atlx/atl1.h
 create mode 100644 drivers/net/atlx/atlx.c
 create mode 100644 drivers/net/atlx/atlx.h

