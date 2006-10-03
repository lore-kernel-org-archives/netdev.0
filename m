From: Santiago Leon <santil@us.ibm.com>
Subject: [PATCH 4/5] ibmveth: rename proc entry name
Date: Tue, 03 Oct 2006 12:24:39 -0500
Message-ID: <20061003172439.14851.52034.sendpatchset@ltcml8p1.rchland.ibm.com>
References: <20061003172417.14851.63625.sendpatchset@ltcml8p1.rchland.ibm.com>
Cc: Santiago Leon <santil@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:47791 "EHLO
	e31.co.us.ibm.com") by vger.kernel.org with ESMTP id S1030456AbWJCS12
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 14:27:28 -0400
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k93IRSQl018018
	for <netdev@vger.kernel.org>; Tue, 3 Oct 2006 14:27:28 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k93IRRBh175708
	for <netdev@vger.kernel.org>; Tue, 3 Oct 2006 12:27:27 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k93IRR6q027334
	for <netdev@vger.kernel.org>; Tue, 3 Oct 2006 12:27:27 -0600
To: netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20061003172417.14851.63625.sendpatchset@ltcml8p1.rchland.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Santiago Leon <santil@us.ibm.com>

This patch changes the name of the proc file for each ibmveth adapter from the network device name to the slot number in the virtual bus.

The proc file is created when the device is probed, so a change in the name of the device will not be reflected in the name of the proc file giving problems when identifying and removing the adapter.  The slot number is a property that does not change through the life of the adapter so we use that instead.

Signed-off-by: Santiago Leon <santil@us.ibm.com>
---
 drivers/net/ibmveth.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -1165,7 +1165,9 @@ static void ibmveth_proc_register_adapte
 {
 	struct proc_dir_entry *entry;
 	if (ibmveth_proc_dir) {
-		entry = create_proc_entry(adapter->netdev->name, S_IFREG, ibmveth_proc_dir);
+		char u_addr[10];
+		sprintf(u_addr, "%x", adapter->vdev->unit_address);
+		entry = create_proc_entry(u_addr, S_IFREG, ibmveth_proc_dir);
 		if (!entry) {
 			ibmveth_error_printk("Cannot create adapter proc entry");
 		} else {
@@ -1180,7 +1182,9 @@ static void ibmveth_proc_register_adapte
 static void ibmveth_proc_unregister_adapter(struct ibmveth_adapter *adapter)
 {
 	if (ibmveth_proc_dir) {
-		remove_proc_entry(adapter->netdev->name, ibmveth_proc_dir);
+		char u_addr[10];
+		sprintf(u_addr, "%x", adapter->vdev->unit_address);
+		remove_proc_entry(u_addr, ibmveth_proc_dir);
 	}
 }
 
