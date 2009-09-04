From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-next PATCH 10/11] enic: bug fix: check for zero port MTU before
	posting warning
Date: Thu, 03 Sep 2009 20:02:40 -0700
Message-ID: <20090904030240.5047.72108.stgit@palito_client100.nuovasystems.com>
References: <20090904030046.5047.46509.stgit@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:19010 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932789AbZIDDCh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 23:02:37 -0400
In-Reply-To: <20090904030046.5047.46509.stgit@palito_client100.nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enic: bug fix: check for zero port MTU before posting warning

Nic firmware can return zero for port MTU, so check for non-zero value
before checking for change in port MTU.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
---
 drivers/net/enic/enic_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 3a55669..9368dae 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -362,7 +362,7 @@ static void enic_mtu_check(struct enic *enic)
 {
 	u32 mtu = vnic_dev_mtu(enic->vdev);
 
-	if (mtu != enic->port_mtu) {
+	if (mtu && mtu != enic->port_mtu) {
 		if (mtu < enic->netdev->mtu)
 			printk(KERN_WARNING PFX
 				"%s: interface MTU (%d) set higher "

