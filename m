From: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>
Subject: [PATCH v2 0/3] drivers: net: cpsw: Fix bugs in fixed-link PHY DT parsing
Date: Wed, 16 Dec 2015 23:02:08 -0500
Message-ID: <cover.1450309613.git.drivshin@allworx.com>
References: <20151209223115.6c5a400f.drivshin.allworx@gmail.com> <1741588.Ve76Z1ZI87@localhost>
Cc: linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Markus Brunner <systemprogrammierung.brunner@gmail.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Pascal Speck <kernel@iktek.de>,
	Daniel Trautmann <dtrautmann@ibhsoftec-sps.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:35551 "EHLO
	mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755374AbbLQECn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 23:02:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 1f71e8c96fc654724723ce987e0a8b2aeb81746d ("drivers: net: cpsw:
Add support for fixed-link PHY") added initial fixed-link PHY support
for CPSW, but missed a few considerations.

This series is based on the tip of the net tree. The first two patches
fix user-visible errors in different hardware configurations. The third
patch is for an internal reference counting issue. They are logically
independent changes, but in the same function, so must be applied in
order to apply cleanly.

The first patch was originally submitted by Pascal Speck on December 4,
but was not picked up by patchwork. I suspect that is because the patch
was mangled by the mailer. I fixed the mangling and am including it in
this series, as I believe it is the correct change.

I have tested on the following hardware configurations:
 - (EVMSK) dual emac with two real MDIO-connected phys using RGMII-TXID
 - single emac with fixed-link using RGMII
Testing of other CPSW emac configurations that folks may have would
be appreciated.


Changes from v1 [1]:
 - Split into 3 smaller patches.
 - Maintain 1f71e8c96fc6's preference for fixed-link over phy_id if
   they are both (incorrectly) specified in the slave node.
 - Update binding documentation to no longer say that phy_mode is also
   mutually exclusive with fixed-link.
 - Dropped unnecessary include of phy_fixed.h.

[1] https://patchwork.ozlabs.org/patch/554989/

David Rivshin (2):
  drivers: net: cpsw: fix RMII/RGMII mode when used with fixed-link PHY
  drivers: net: cpsw: increment reference count on fixed-link PHY node

Pascal Speck (Iktek) (1):
  ethernet:ti:cpsw: fix phy identification with multiple slaves on
    fixed-phy

 Documentation/devicetree/bindings/net/cpsw.txt |  6 +--
 drivers/net/ethernet/ti/cpsw.c                 | 53 +++++++++++++++-----------
 2 files changed, 34 insertions(+), 25 deletions(-)

--
2.5.0
