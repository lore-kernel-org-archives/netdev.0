From: Michael Dilmore <michael.j.dilmore@gmail.com>
Subject: [PATCH] Add printk for bonding module packets_per_slave parameter
Date: Tue, 13 Jun 2017 14:42:46 +0100
Message-ID: <20170613134246.6407-1-michael.j.dilmore@gmail.com>
Cc: Michael Dilmore <michael.j.dilmore@gmail.com>,
        Veaceslav Falico <vfalico@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jay Vosburgh <j.vosburgh@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:36722 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753208AbdFMNnG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 09:43:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The packets per slave parameter used by round robin mode does not have a printk debug
message in its set function in bond_options.c. Adding such a function would aid debugging
of round-robin mode and allow the user to more easily verify that the parameter has been
set correctly. I should add that I'm motivated by my own experience here - it's not
obvious from output of tools such as wireshark and ifstat that the parameter is working
correctly, and with the differences in bonding configuration across different distributions,
it would have been comforting to see this output.

Signed-off-by: Michael Dilmore <michael.j.dilmore@gmail.com>

cc: Veaceslav Falico <vfalico@gmail.com>,Andy Gospodarek <andy@greyhouse.net>,netdev@vger.kernel.org,linux-kernel@vger.kernel.org
---
 drivers/net/bonding/bond_options.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 1bcbb8913e17..4da0de1bab0a 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -1233,6 +1233,8 @@ static int bond_option_lp_interval_set(struct bonding *bond,
 static int bond_option_pps_set(struct bonding *bond,
 			       const struct bond_opt_value *newval)
 {
+	netdev_info(bond->dev, "Setting packets per slave to %d\n",
+		    newval->value);
 	bond->params.packets_per_slave = newval->value;
 	if (newval->value > 0) {
 		bond->params.reciprocal_packets_per_slave =
-- 
2.11.0
