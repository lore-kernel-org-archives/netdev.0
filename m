From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [Ubuntu PATCH] Make tulip driver not handle Davicom NICs
Date: Wed, 14 Jun 2006 16:23:36 -0700
Message-ID: <44909A78.4@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:2111 "EHLO
	agminet01.oracle.com") by vger.kernel.org with ESMTP
	id S964783AbWFNWXF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jun 2006 18:23:05 -0400
To: netdev <netdev@vger.kernel.org>, akpm <akpm@osdl.org>,
	val_henson@linux.intel.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make tulip driver not handle Davicom NICs, let dmfe take over"

Reference: https://launchpad.net/bugs/48287
Source URL of Patch:
http://www.kernel.org/git/?p=linux/kernel/git/bcollins/ubuntu-dapper.git;a=commitdiff;h=1804482911a71bee9114cae1c2079507a38e9e7f


--- linux-2.6.17-rc5/drivers/net/tulip/tulip_core.c	2006-06-05 09:20:30.000000000 +0800
+++ ubuntu-kernel/drivers/net/tulip/tulip_core.c	2006-06-05 09:56:55.000000000 +0800
@@ -223,8 +223,12 @@
 	{ 0x1259, 0xa120, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMET },
 	{ 0x11F6, 0x9881, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMPEX9881 },
 	{ 0x8086, 0x0039, PCI_ANY_ID, PCI_ANY_ID, 0, 0, I21145 },
+	/* dmfe module seems to handle these better. See:
+ 	 * https://launchpad.net/bugs/48287 */
+#if 0
 	{ 0x1282, 0x9100, PCI_ANY_ID, PCI_ANY_ID, 0, 0, DM910X },
 	{ 0x1282, 0x9102, PCI_ANY_ID, PCI_ANY_ID, 0, 0, DM910X },
+#endif
 	{ 0x1113, 0x1216, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMET },
 	{ 0x1113, 0x1217, PCI_ANY_ID, PCI_ANY_ID, 0, 0, MX98715 },
 	{ 0x1113, 0x9511, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMET },

