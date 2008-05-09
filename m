From: Brice Goglin <brice@myri.com>
Subject: [PATCH 09/16] myri10ge: fix potential infinite loop in enable_ecrc
Date: Fri, 09 May 2008 02:19:29 +0200
Message-ID: <48239891.9020107@myri.com>
References: <482397A3.1050604@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1813 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755129AbYEIAqM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 May 2008 20:46:12 -0400
In-Reply-To: <482397A3.1050604@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix another potential for an infinite loop while looking for the
root port in myri10ge_enable_ecrc().

Signed-off-by: Brice Goglin <brice@myri.com>
Signed-off-by: Andrew Gallatin <gallatin@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

Index: linux-2.6/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-2.6.orig/drivers/net/myri10ge/myri10ge.c	2008-05-09 00:06:20.000000000 +0200
+++ linux-2.6/drivers/net/myri10ge/myri10ge.c	2008-05-09 00:07:17.000000000 +0200
@@ -2657,13 +2657,14 @@
 	ext_type = (val & PCI_EXP_FLAGS_TYPE) >> 4;
 	if (ext_type != PCI_EXP_TYPE_ROOT_PORT) {
 		if (myri10ge_ecrc_enable > 1) {
-			struct pci_dev *old_bridge = bridge;
+			struct pci_dev *prev_bridge, *old_bridge = bridge;
 
 			/* Walk the hierarchy up to the root port
 			 * where ECRC has to be enabled */
 			do {
+				prev_bridge = bridge;
 				bridge = bridge->bus->self;
-				if (!bridge) {
+				if (!bridge || prev_bridge == bridge) {
 					dev_err(dev,
 						"Failed to find root port"
 						" to force ECRC\n");


