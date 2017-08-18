From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 05/10] net: make net sysfs attributes ro_after_init
Date: Fri, 18 Aug 2017 13:46:23 -0700
Message-ID: <20170818204628.17147-6-sthemmin@microsoft.com>
References: <20170818204628.17147-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:33576 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752071AbdHRUqm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 16:46:42 -0400
Received: by mail-pg0-f46.google.com with SMTP id t3so43027638pgt.0
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 13:46:41 -0700 (PDT)
In-Reply-To: <20170818204628.17147-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The attributes of net devices are immutable.

Ideally, attribute groups would contain const attributes
but there are too many places that do modifications of list
during startup (in other code) to allow that.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 net/core/net-sysfs.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 2de441692f28..76ec74d4a65b 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -508,7 +508,7 @@ static ssize_t phys_switch_id_show(struct device *dev,
 }
 static DEVICE_ATTR_RO(phys_switch_id);
 
-static struct attribute *net_class_attrs[] = {
+static struct attribute *net_class_attrs[] __ro_after_init = {
 	&dev_attr_netdev_group.attr,
 	&dev_attr_type.attr,
 	&dev_attr_dev_id.attr,
@@ -597,7 +597,7 @@ NETSTAT_ENTRY(rx_compressed);
 NETSTAT_ENTRY(tx_compressed);
 NETSTAT_ENTRY(rx_nohandler);
 
-static struct attribute *netstat_attrs[] = {
+static struct attribute *netstat_attrs[] __ro_after_init = {
 	&dev_attr_rx_packets.attr,
 	&dev_attr_tx_packets.attr,
 	&dev_attr_rx_bytes.attr,
-- 
2.11.0
