From: Jay Vosburgh <fubar@us.ibm.com>
Subject: %pI4 vs. NIPQUAD: %pI4 doing it wrong?
Date: Mon, 03 Nov 2008 17:05:29 -0800
Message-ID: <15026.1225760729@death.nxdomain.ibm.com>
Cc: Harvey Harrison <harvey.harrison@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:58719 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754040AbYKDBFf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 20:05:35 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id mA414oV5016790
	for <netdev@vger.kernel.org>; Mon, 3 Nov 2008 18:04:50 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mA415Y1G118682
	for <netdev@vger.kernel.org>; Mon, 3 Nov 2008 18:05:34 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mA4153r5029340
	for <netdev@vger.kernel.org>; Mon, 3 Nov 2008 18:05:04 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Running the latest net-next-2.6, I notice that %pI4 is
apparently printing IPv4 addresses incorrectly (and differently than the
NIPQUAD it replaced).

	The following is excerpted from the bonding driver's
/proc/net/bonding/bond0 status file:

[...]
ARP IP target/s (n.n.n.n form): 01.0.1.1 (10.0.1.1), 01.02.03.04 (10.20.30.40)

	The first (incorrect) values are from %pI4, the ones in
parentheses (which are correct) I added as a check using NIPQUAD with
this patch:

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 56c823c..ced12ba 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3289,7 +3289,9 @@ static void bond_info_show_master(struct seq_file *seq)
 				continue;
 			if (printed)
 				seq_printf(seq, ",");
-			seq_printf(seq, " %pI4", &bond->params.arp_targets[i]);
+			seq_printf(seq, " %pI4 (%u.%u.%u.%u)",
+				   &bond->params.arp_targets[i],
+				   NIPQUAD(bond->params.arp_targets[i]));
 			printed = 1;
 		}
 		seq_printf(seq, "\n");

	Is anybody else seeing this, or is it just me?

	I'm working on an x86.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
