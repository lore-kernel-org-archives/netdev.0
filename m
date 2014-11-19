From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/15] i40evf: make comparisons consistent
Date: Tue, 18 Nov 2014 20:10:54 -0800
Message-ID: <1416370256-16834-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1416370256-16834-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:4973 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754564AbaKSELK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Nov 2014 23:11:10 -0500
In-Reply-To: <1416370256-16834-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Most of the null-checking in this driver is of the style if (!foo),
except these few. Make these checks consistent with the rest of the
code.

Change-ID: I991924f34072fa607a1b626a8b3f1fa5195d43e9
Reported-by: Joe Perches <joe@perches.com>
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 777d3a5..233710c 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -669,9 +669,9 @@ i40evf_vlan_filter *i40evf_add_vlan(struct i40evf_adapter *adapter, u16 vlan)
 	struct i40evf_vlan_filter *f;
 
 	f = i40evf_find_vlan(adapter, vlan);
-	if (NULL == f) {
+	if (!f) {
 		f = kzalloc(sizeof(*f), GFP_ATOMIC);
-		if (NULL == f)
+		if (!f)
 			return NULL;
 
 		f->vlan = vlan;
@@ -774,9 +774,9 @@ i40evf_mac_filter *i40evf_add_filter(struct i40evf_adapter *adapter,
 		udelay(1);
 
 	f = i40evf_find_filter(adapter, macaddr);
-	if (NULL == f) {
+	if (!f) {
 		f = kzalloc(sizeof(*f), GFP_ATOMIC);
-		if (NULL == f) {
+		if (!f) {
 			clear_bit(__I40EVF_IN_CRITICAL_TASK,
 				  &adapter->crit_section);
 			return NULL;
@@ -2138,7 +2138,7 @@ static void i40evf_init_task(struct work_struct *work)
 	ether_addr_copy(netdev->perm_addr, adapter->hw.mac.addr);
 
 	f = kzalloc(sizeof(*f), GFP_ATOMIC);
-	if (NULL == f)
+	if (!f)
 		goto err_sw_init;
 
 	ether_addr_copy(f->macaddr, adapter->hw.mac.addr);
-- 
1.9.3
