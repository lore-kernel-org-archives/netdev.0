From: Thomas Klein <osstklei@de.ibm.com>
Subject: [PATCH 2.6.20-rc5 3/7] ehea: Modified initial autoneg state determination
Date: Mon, 22 Jan 2007 12:53:20 +0100
Message-ID: <200701221253.20959.osstklei@de.ibm.com>
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
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751751AbXAVLxZ@vger.kernel.org>
Content-Disposition: inline
To: Jeff Garzik <jeff@garzik.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Logical partitions are not allowed to (try to) set the autonegotiation status.
This patch removes the respective function call from the port setup function.

Signed-off-by: Thomas Klein <tklein@de.ibm.com>
---


 drivers/net/ehea/ehea_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)


diff -Nurp -X dontdiff linux-2.6.20-rc5/drivers/net/ehea/ehea_main.c patched_kernel/drivers/net/ehea/ehea_main.c
--- linux-2.6.20-rc5/drivers/net/ehea/ehea_main.c	2007-01-19 14:02:20.000000000 +0100
+++ patched_kernel/drivers/net/ehea/ehea_main.c	2007-01-19 14:11:30.000000000 +0100
@@ -642,6 +642,8 @@ int ehea_sense_port_attr(struct ehea_por
 		break;
 	}
 
+	port->autoneg = 1;
+
 	/* Number of default QPs */
 	port->num_def_qps = cb0->num_default_qps;
 
@@ -2334,8 +2336,6 @@ static int ehea_setup_single_port(struct
 
 	INIT_LIST_HEAD(&port->mc_list->list);
 
-	ehea_set_portspeed(port, EHEA_SPEED_AUTONEG);
-
 	ret = ehea_sense_port_attr(port);
 	if (ret)
 		goto out;
