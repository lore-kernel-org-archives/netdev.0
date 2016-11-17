From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net v2 0/7] net: cpsw: fix leaks and probe deferral
Date: Thu, 17 Nov 2016 17:39:57 +0100
Message-ID: <1479400804-9847-1-git-send-email-johan@kernel.org>
Cc: Grygorii Strashko <grygorii.strashko@ti.com>,
        linux-omap@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Johan Hovold <johan@kernel.org>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series fixes as number of leaks and issues in the cpsw probe-error
and driver-unbind paths, some which specifically prevented deferred
probing.

Johan


v2
 - Keep platform device runtime-resumed throughout probe instead of
   resuming in the probe error path as suggested by Grygorii (patch
   1/7).

 - Runtime-resume platform device before registering any children in
   order to make sure it is synchronously suspended after deregistering
   children in the error path (patch 3/7).


Johan Hovold (7):
  net: ethernet: ti: cpsw: fix bad register access in probe error path
  net: ethernet: ti: cpsw: fix mdio device reference leak
  net: ethernet: ti: cpsw: fix deferred probe
  net: ethernet: ti: cpsw: fix of_node and phydev leaks
  net: ethernet: ti: cpsw: fix secondary-emac probe error path
  net: ethernet: ti: cpsw: add missing sanity check
  net: ethernet: ti: cpsw: fix fixed-link phy probe deferral

 drivers/net/ethernet/ti/cpsw.c | 95 ++++++++++++++++++++++++++++++++----------
 1 file changed, 74 insertions(+), 21 deletions(-)

-- 
2.7.3
