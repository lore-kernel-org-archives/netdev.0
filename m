From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH] sfc: initialize dynamic sysfs attributes for lockdep
Date: Thu, 19 Jul 2012 19:04:45 +0200
Message-ID: <1342717485-24034-1-git-send-email-mschmidt@redhat.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31418 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751313Ab2GSREx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2012 13:04:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dynamically allocated sysfs attributes must be initialized using
sysfs_attr_init(), otherwise lockdep complains:
BUG: key <address> not in .data!

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/sfc/mcdi_mon.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/sfc/mcdi_mon.c b/drivers/net/ethernet/sfc/mcdi_mon.c
index fb7f65b..1d552f0 100644
--- a/drivers/net/ethernet/sfc/mcdi_mon.c
+++ b/drivers/net/ethernet/sfc/mcdi_mon.c
@@ -222,6 +222,7 @@ efx_mcdi_mon_add_attr(struct efx_nic *efx, const char *name,
 	attr->index = index;
 	attr->type = type;
 	attr->limit_value = limit_value;
+	sysfs_attr_init(&attr->dev_attr.attr);
 	attr->dev_attr.attr.name = attr->name;
 	attr->dev_attr.attr.mode = S_IRUGO;
 	attr->dev_attr.show = reader;
-- 
1.7.10.4
