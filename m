From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH] atl1: disable TSO by default
Date: Mon, 18 Aug 2008 19:28:13 -0500
Message-ID: <20080818192813.0d0dc1fd@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	link@miggy.org, ian@jeffray.co.uk, csnook@redhat.com,
	jie.yang@atheros.com, m@fhloston.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost06.isp.att.net ([204.127.217.106]:39362 "EHLO
	fmailhost06.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751952AbYHSA2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 20:28:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The atl1 driver is causing stalled connections and file corruption
whenever TSO is enabled.  Two examples are here:

http://lkml.org/lkml/2008/7/15/325
http://lkml.org/lkml/2008/8/18/543

Disable TSO by default until we can determine the source of the
problem.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
cc: stable@kernel.org
---

Jeff, I've been trying to find the source of this problem in my
spare time for a few weeks now, but haven't been successful.  We
turned on TSO by default in 2.6.26 after fixing a nasty performance
bug in it, but there's apparently another bug lurking.

This patch needs to be also applied to 2.6.26, hence the cc to
stable.

 drivers/net/atlx/atl1.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index e6a7bb7..e23ce77 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -3022,7 +3022,6 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 	netdev->features = NETIF_F_HW_CSUM;
 	netdev->features |= NETIF_F_SG;
 	netdev->features |= (NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX);
-	netdev->features |= NETIF_F_TSO;
 	netdev->features |= NETIF_F_LLTX;
 
 	/*
-- 
1.5.5.1
