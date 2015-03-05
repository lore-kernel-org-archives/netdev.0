From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 4/5] net: dsa: let switches specify their tagging protocol
Date: Thu,  5 Mar 2015 12:35:07 -0800
Message-ID: <1425587708-26786-5-git-send-email-f.fainelli@gmail.com>
References: <1425587708-26786-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:38664 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754499AbbCEUgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 15:36:19 -0500
Received: by pdbfl12 with SMTP id fl12so37946070pdb.5
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 12:36:17 -0800 (PST)
In-Reply-To: <1425587708-26786-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to support the new DSA device driver model, a dsa_switch should
be able to advertise the type of tagging protocol supported by the
underlying switch device. This also removes constraints on how tagging
can be stacked to each other.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h | 5 +++++
 net/dsa/dsa.c     | 5 +++--
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index c542c131d551..b525ac516559 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -128,6 +128,11 @@ struct dsa_switch {
 	int			index;
 
 	/*
+	 * Tagging protocol understood by this switch
+	 */
+	enum dsa_tag_protocol	tag_protocol;
+
+	/*
 	 * Configuration data for this switch.
 	 */
 	struct dsa_chip_data	*pd;
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 6f02ccc57593..4cc995664fdf 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -227,7 +227,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 	 * switch.
 	 */
 	if (dst->cpu_switch == index) {
-		switch (drv->tag_protocol) {
+		switch (ds->tag_protocol) {
 #ifdef CONFIG_NET_DSA_TAG_DSA
 		case DSA_TAG_PROTO_DSA:
 			dst->rcv = dsa_netdev_ops.rcv;
@@ -255,7 +255,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 			goto out;
 		}
 
-		dst->tag_protocol = drv->tag_protocol;
+		dst->tag_protocol = ds->tag_protocol;
 	}
 
 	/*
@@ -364,6 +364,7 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 	ds->index = index;
 	ds->pd = pd;
 	ds->drv = drv;
+	ds->tag_protocol = drv->tag_protocol;
 	ds->master_dev = host_dev;
 
 	ret = dsa_switch_setup_one(ds, parent);
-- 
2.1.0
