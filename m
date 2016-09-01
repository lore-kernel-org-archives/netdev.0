From: Jeremy Linton <jeremy.linton@arm.com>
Subject: [PATCH v3 0/4] net: smsc911x: Move phy and interrupt config
Date: Thu,  1 Sep 2016 15:15:05 -0500
Message-ID: <1472760909-19688-1-git-send-email-jeremy.linton@arm.com>
Cc: steve.glendinning@shawell.net, sergei.shtylyov@cogentembedded.com,
        andrew@lunn.ch, will.deacon@arm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:39370 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934253AbcIAVdv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Sep 2016 17:33:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2-v3: Move error handing into separate patch, replace a couple cases
 of fixed errors with the errors being returned from the failing functions.
 Hoist irq handler.

The smsc911x driver is doing a number of things in its probe routine that
should be delayed until the interface is started. Because of this, the module
cannot be unloaded, the phy states are incorrect/stale if the interface isn't
running, open's unnecessarily fail causing network configuration problems, and
the /proc/irq nodes are incorrectly named.

Clean up a number of these problems by moving the mdio and interrupt
configuration into the smsc911x_open routine.

Jeremy Linton (4):
  net: smsc911x: Remove multiple exit points from smsc911x_open
  net: smsc911x: Fix register_netdev, phy startup, driver unload
    ordering
  net: smsc911x: Move interrupt handler before open
  net: smsc911x: Move interrupt allocation to open/stop

 drivers/net/ethernet/smsc/smsc911x.c | 213 +++++++++++++++++------------------
 1 file changed, 104 insertions(+), 109 deletions(-)

-- 
2.5.5
