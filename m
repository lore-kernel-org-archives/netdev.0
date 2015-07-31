From: Joe Perches <joe@perches.com>
Subject: [PATCH] br2684: Remove unnecessary formatting macros b1 and bs
Date: Thu, 30 Jul 2015 23:54:28 -0700
Message-ID: <1438325668.19675.54.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0010.hostedemail.com ([216.40.44.10]:32956 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752107AbbGaGyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 02:54:31 -0400
Received: from filter.hostedemail.com (unknown [216.40.38.60])
	by smtprelay06.hostedemail.com (Postfix) with ESMTP id 4E1909EA1C
	for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 06:54:30 +0000 (UTC)
Received: from joe-X200MA.home (pool-173-51-221-2.lsanca.fios.verizon.net [173.51.221.2])
	(Authenticated sender: joe@perches.com)
	by omf02.hostedemail.com (Postfix) with ESMTPA
	for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 06:54:29 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use vsprintf extension %pI4 instead.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/atm/br2684.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index cc78538..aa0047c 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -802,13 +802,10 @@ static int br2684_seq_show(struct seq_file *seq, void *v)
 			   (brdev->payload == p_bridged) ? "bridged" : "routed",
 			   brvcc->copies_failed, brvcc->copies_needed);
 #ifdef CONFIG_ATM_BR2684_IPFILTER
-#define b1(var, byte)	((u8 *) &brvcc->filter.var)[byte]
-#define bs(var)		b1(var, 0), b1(var, 1), b1(var, 2), b1(var, 3)
 		if (brvcc->filter.netmask != 0)
-			seq_printf(seq, "    filter=%d.%d.%d.%d/"
-				   "%d.%d.%d.%d\n", bs(prefix), bs(netmask));
-#undef bs
-#undef b1
+			seq_printf(seq, "    filter=%pI4/%pI4\n",
+				   &brvcc->filter.prefix,
+				   &brvcc->filter.netmask);
 #endif /* CONFIG_ATM_BR2684_IPFILTER */
 	}
 	return 0;
