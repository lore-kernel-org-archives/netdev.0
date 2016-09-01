From: Jeremy Linton <jeremy.linton@arm.com>
Subject: [PATCH 0/2] net: smsc911x: Move phy and interrupt config
Date: Thu,  1 Sep 2016 11:25:39 -0500
Message-ID: <1472747141-15886-1-git-send-email-jeremy.linton@arm.com>
Cc: steve.glendinning@shawell.net, sergei.shtylyov@cogentembedded.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:35044 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752968AbcIAQZm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Sep 2016 12:25:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The smsc911x driver is doing a number of things in its probe routine that
should be delayed until the interface is started. Because of this, the module
cannot be unloaded, the phy states are incorrect/stale if the interface isn't
running, open's unnecessarily fail causing network configuration problems, and
the /proc/irq nodes are incorrectly named.

Clean up a number of these problems by moving the mdio and interrupt
configuration into the smsc911x_open routine.

Jeremy Linton (2):
  net: smsc911x: Fix register_netdev, phy startup, driver unload
    ordering
  net/smsc911x: Move interrupt allocation to open/stop

 drivers/net/ethernet/smsc/smsc911x.c | 89 +++++++++++++++++-------------------
 1 file changed, 42 insertions(+), 47 deletions(-)

-- 
2.5.5
