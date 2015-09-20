From: sfeldma@gmail.com
Subject: [PATCH net-next v2 4/7] rocker: adding port ageing_time for ageing out FDB entries
Date: Sun, 20 Sep 2015 08:48:26 -0700
Message-ID: <1442764109-11110-5-git-send-email-sfeldma@gmail.com>
References: <1442764109-11110-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, siva.mannem.lnx@gmail.com, pjonnala@broadcom.com,
	stephen@networkplumber.org, roopa@cumulusnetworks.com,
	andrew@lunn.ch, f.fainelli@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35816 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753558AbbITPpr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Sep 2015 11:45:47 -0400
Received: by pacfv12 with SMTP id fv12so95508225pac.2
        for <netdev@vger.kernel.org>; Sun, 20 Sep 2015 08:45:46 -0700 (PDT)
In-Reply-To: <1442764109-11110-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Follow-up patcheset will allow user to change ageing_time, but for now
just hard-code it to a fixed value (the same value used as the default
for the bridge driver).

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index f55ed2c..be8bb04 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -221,6 +221,7 @@ struct rocker_port {
 	__be16 internal_vlan_id;
 	int stp_state;
 	u32 brport_flags;
+	unsigned long ageing_time;
 	bool ctrls[ROCKER_CTRL_MAX];
 	unsigned long vlan_bitmap[ROCKER_VLAN_BITMAP_LEN];
 	struct napi_struct napi_tx;
@@ -4975,6 +4976,7 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 	rocker_port->port_number = port_number;
 	rocker_port->pport = port_number + 1;
 	rocker_port->brport_flags = BR_LEARNING | BR_LEARNING_SYNC;
+	rocker_port->ageing_time = BR_DEFAULT_AGEING_TIME;
 	INIT_LIST_HEAD(&rocker_port->trans_mem);
 
 	rocker_port_dev_addr_init(rocker_port);
-- 
1.7.10.4
