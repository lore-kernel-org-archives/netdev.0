From: Thomas Klein <osstklei@de.ibm.com>
Subject: [PATCH 2.6.20-rc5 7/7] ehea: Fixed possible nullpointer access
Date: Mon, 22 Jan 2007 12:55:20 +0100
Message-ID: <200701221255.20768.osstklei@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <ossthema@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <roscher@de.ibm.com>,
	Stefan Roscher <ossrosch@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:47879 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751698AbXAVL4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jan 2007 06:56:42 -0500
Content-Disposition: inline
To: Jeff Garzik <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixed possible nullpointer access in event queue processing

Signed-off-by: Thomas Klein <tklein@de.ibm.com>
---


 drivers/net/ehea/ehea_main.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)


diff -Nurp -X dontdiff linux-2.6.20-rc5/drivers/net/ehea/ehea_main.c patched_kernel/drivers/net/ehea/ehea_main.c
--- linux-2.6.20-rc5/drivers/net/ehea/ehea_main.c	2007-01-19 14:33:04.000000000 +0100
+++ patched_kernel/drivers/net/ehea/ehea_main.c	2007-01-19 14:36:05.000000000 +0100
@@ -575,8 +575,9 @@ static struct ehea_port *ehea_get_port(s
 	int i;
 
 	for (i = 0; i < adapter->num_ports; i++)
-		if (adapter->port[i]->logical_port_id == logical_port)
-			return adapter->port[i];
+		if (adapter->port[i])
+	                if (adapter->port[i]->logical_port_id == logical_port)
+				return adapter->port[i];
 	return NULL;
 }
 

