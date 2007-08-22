From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH 1/4] ehea: fix interface to DLPAR tools
Date: Wed, 22 Aug 2007 16:20:58 +0200
Message-ID: <200708221620.59078.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:43620 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758722AbXHVOxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 10:53:19 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Userspace DLPAR tool expects decimal numbers to be written to
and read from sysfs entries.

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>


---
 drivers/net/ehea/ehea_main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 9756211..22d000f 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -2490,7 +2490,7 @@ static ssize_t ehea_show_port_id(struct device *dev,
 				 struct device_attribute *attr, char *buf)
 {
 	struct ehea_port *port = container_of(dev, struct ehea_port, ofdev.dev);
-	return sprintf(buf, "0x%X", port->logical_port_id);
+	return sprintf(buf, "%d", port->logical_port_id);
 }
 
 static DEVICE_ATTR(log_port_id, S_IRUSR | S_IRGRP | S_IROTH, ehea_show_port_id,
@@ -2781,7 +2781,7 @@ static ssize_t ehea_probe_port(struct device *dev,
 
 	u32 logical_port_id;
 
-	sscanf(buf, "%X", &logical_port_id);
+	sscanf(buf, "%d", &logical_port_id);
 
 	port = ehea_get_port(adapter, logical_port_id);
 
@@ -2834,7 +2834,7 @@ static ssize_t ehea_remove_port(struct device *dev,
 	int i;
 	u32 logical_port_id;
 
-	sscanf(buf, "%X", &logical_port_id);
+	sscanf(buf, "%d", &logical_port_id);
 
 	port = ehea_get_port(adapter, logical_port_id);
 
-- 
1.5.2

