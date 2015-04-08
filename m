From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 0/2] sfc: Nic specific sriov functions, netdev_ops
 and sriov_configure
Date: Wed, 8 Apr 2015 15:22:50 +0100
Message-ID: <552539BA.6070707@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:31301 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932326AbbDHO1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 10:27:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First two patches among the series of patches to support SRIOV on EF10.

First patch declares nic specific sriov functions in nic specific headers,
creates only one instance of the netdev_ops, removes sriov functionality
from Falcon code.

Second patch adds support for sriov_configure.

The Virtual Functions can be enabled but they do not bind to the SFC
driver just yet.

Shradha Shah (2):
  sfc: Own header for nic-specific sriov functions, single instance of
    netdev_ops and sriov removed from Falcon code
  sfc: Enable VF's via a write to the sysfs file sriov_numvfs

 drivers/net/ethernet/sfc/Makefile      |   2 +-
 drivers/net/ethernet/sfc/ef10.c        |   7 ++
 drivers/net/ethernet/sfc/ef10_sriov.c  |  52 +++++++++++++++
 drivers/net/ethernet/sfc/ef10_sriov.h  |  58 ++++++++++++++++
 drivers/net/ethernet/sfc/efx.c         | 118 ++++++++++++++++++---------------
 drivers/net/ethernet/sfc/efx.h         |   7 ++
 drivers/net/ethernet/sfc/falcon.c      |  10 ---
 drivers/net/ethernet/sfc/farch.c       |  48 ++++++++------
 drivers/net/ethernet/sfc/mcdi.c        |   4 +-
 drivers/net/ethernet/sfc/net_driver.h  |   9 +++
 drivers/net/ethernet/sfc/nic.h         | 111 -------------------------------
 drivers/net/ethernet/sfc/siena.c       |   7 ++
 drivers/net/ethernet/sfc/siena_sriov.c |  58 +++++++++++++---
 drivers/net/ethernet/sfc/siena_sriov.h |  79 ++++++++++++++++++++++
 drivers/net/ethernet/sfc/sriov.c       |  64 ++++++++++++++++++
 drivers/net/ethernet/sfc/sriov.h       |  27 ++++++++
 16 files changed, 454 insertions(+), 207 deletions(-)
 create mode 100644 drivers/net/ethernet/sfc/ef10_sriov.c
 create mode 100644 drivers/net/ethernet/sfc/ef10_sriov.h
 create mode 100644 drivers/net/ethernet/sfc/siena_sriov.h
 create mode 100644 drivers/net/ethernet/sfc/sriov.c
 create mode 100644 drivers/net/ethernet/sfc/sriov.h
