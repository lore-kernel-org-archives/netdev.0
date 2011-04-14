From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] qlge: make nic_operations struct const
Date: Thu, 14 Apr 2011 08:51:52 -0700
Message-ID: <20110414085152.042a79e4@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-driver@qlogic.com
To: Ron Mercer <ron.mercer@qlogic.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44860 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756559Ab1DNPvy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Apr 2011 11:51:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The struct nic_operations is just function pointers and should be
declared const for added security.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/qlge/qlge.h	2011-04-14 08:31:15.863779054 -0700
+++ b/drivers/net/qlge/qlge.h	2011-04-14 08:31:19.231840948 -0700
@@ -2134,7 +2134,7 @@ struct ql_adapter {
 	struct delayed_work mpi_idc_work;
 	struct delayed_work mpi_core_to_log;
 	struct completion ide_completion;
-	struct nic_operations *nic_ops;
+	const struct nic_operations *nic_ops;
 	u16 device_id;
 	struct timer_list timer;
 	atomic_t lb_count;
--- a/drivers/net/qlge/qlge_main.c	2011-04-14 08:30:32.311185557 -0700
+++ b/drivers/net/qlge/qlge_main.c	2011-04-14 08:31:07.595627135 -0700
@@ -4412,12 +4412,12 @@ error:
 	rtnl_unlock();
 }
 
-static struct nic_operations qla8012_nic_ops = {
+static const struct nic_operations qla8012_nic_ops = {
 	.get_flash		= ql_get_8012_flash_params,
 	.port_initialize	= ql_8012_port_initialize,
 };
 
-static struct nic_operations qla8000_nic_ops = {
+static const struct nic_operations qla8000_nic_ops = {
 	.get_flash		= ql_get_8000_flash_params,
 	.port_initialize	= ql_8000_port_initialize,
 };
