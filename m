From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 1/2] [POWERPC] mpc5200: Fix Kconfig dependancies on MPC5200	FEC
 device driver
Date: Thu, 01 Nov 2007 08:22:30 -0600
Message-ID: <20071101142230.7620.86215.stgit@trillian.cg.shawcable.net>
References: <20071101142005.7620.54250.stgit@trillian.cg.shawcable.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, jgarzik@pobox.com, domen.puncer@telargo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from idcmail-mo1so.shaw.ca ([24.71.223.10]:42023 "EHLO
	pd2mo3so.prod.shaw.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753525AbXKAOXU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 10:23:20 -0400
Received: from pd3mr4so.prod.shaw.ca
 (pd3mr4so-qfe3.prod.shaw.ca [10.0.141.180]) by l-daemon
 (Sun ONE Messaging Server 6.0 HotFix 1.01 (built Mar 15 2004))
 with ESMTP id <0JQT00J2MZXJ8S50@l-daemon> for netdev@vger.kernel.org; Thu,
 01 Nov 2007 08:22:31 -0600 (MDT)
Received: from pn2ml1so.prod.shaw.ca ([10.0.121.145])
 by pd3mr4so.prod.shaw.ca (Sun Java System Messaging Server 6.2-7.05 (built Sep
 5 2006)) with ESMTP id <0JQT00DRSZXINA60@pd3mr4so.prod.shaw.ca> for
 netdev@vger.kernel.org; Thu, 01 Nov 2007 08:22:31 -0600 (MDT)
Received: from trillian.cg.shawcable.net ([68.147.67.118])
 by l-daemon (Sun Java System Messaging Server 6.2-7.05 (built Sep  5 2006))
 with ESMTP id <0JQT00K50ZXHQK00@l-daemon> for netdev@vger.kernel.org; Thu,
 01 Nov 2007 08:22:30 -0600 (MDT)
In-reply-to: <20071101142005.7620.54250.stgit@trillian.cg.shawcable.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grant Likely <grant.likely@secretlab.ca>

When not building an arch/powerpc kernel, the mpc5200 FEC driver depends
on some symbols which are not defined (BESTCOMM & BESTCOMM_FEC).

This patch flips around the dependancy logic so that it cannot be
selected unless BESTCOMM_FEC is selected first.  Kconfig stops
complaining this way.

Also, the driver only works for arch/powerpc (not arch/ppc) anyway so
it should depend on PPC_MERGE also.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/net/Kconfig |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 867cb73..5f800a6 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1883,9 +1883,7 @@ config FEC2
 
 config FEC_MPC52xx
 	tristate "MPC52xx FEC driver"
-	depends on PPC_MPC52xx
-	select PPC_BESTCOMM
-	select PPC_BESTCOMM_FEC
+	depends on PPC_MERGE && PPC_MPC52xx && PPC_BESTCOMM_FEC
 	select CRC32
 	select PHYLIB
 	---help---

