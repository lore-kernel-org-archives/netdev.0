From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 4/5] qeth: sysfs: replace strcmp() with sysfs_streq()
Date: Fri, 16 Jan 2015 14:05:48 +0100
Message-ID: <1421413549-56937-5-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1421413549-56937-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com, ubraun@linux.vnet.ibm.com,
	Eugene Crosser <Eugene.Crosser@ru.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp13.uk.ibm.com ([195.75.94.109]:38644 "EHLO
	e06smtp13.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755536AbbAPNGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 08:06:44 -0500
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Fri, 16 Jan 2015 13:06:42 -0000
In-Reply-To: <1421413549-56937-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugene Crosser <Eugene.Crosser@ru.ibm.com>

Replace combination of strsep() and a temporary char *
followed by a series of "if (!strcmp(...))" with a series
of "if (sysfs_streq(...))".

Signed-off-by: Eugene Crosser <Eugene.Crosser@ru.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Reviewed-by: Thomas-Mich Richter <tmricht@de.ibm.com>
---
 drivers/s390/net/qeth_core_sys.c | 38 ++++++++++++++----------------------
 drivers/s390/net/qeth_l3_sys.c   | 42 ++++++++++++++++------------------------
 2 files changed, 32 insertions(+), 48 deletions(-)

diff --git a/drivers/s390/net/qeth_core_sys.c b/drivers/s390/net/qeth_core_sys.c
index 8c76574..423bec5 100644
--- a/drivers/s390/net/qeth_core_sys.c
+++ b/drivers/s390/net/qeth_core_sys.c
@@ -231,7 +231,6 @@ static ssize_t qeth_dev_prioqing_store(struct device *dev,
 		struct device_attribute *attr, const char *buf, size_t count)
 {
 	struct qeth_card *card = dev_get_drvdata(dev);
-	char *tmp;
 	int rc = 0;
 
 	if (!card)
@@ -253,36 +252,35 @@ static ssize_t qeth_dev_prioqing_store(struct device *dev,
 		goto out;
 	}
 
-	tmp = strsep((char **) &buf, "\n");
-	if (!strcmp(tmp, "prio_queueing_prec")) {
+	if (sysfs_streq(buf, "prio_queueing_prec")) {
 		card->qdio.do_prio_queueing = QETH_PRIO_Q_ING_PREC;
 		card->qdio.default_out_queue = QETH_DEFAULT_QUEUE;
-	} else if (!strcmp(tmp, "prio_queueing_skb")) {
+	} else if (sysfs_streq(buf, "prio_queueing_skb")) {
 		card->qdio.do_prio_queueing = QETH_PRIO_Q_ING_SKB;
 		card->qdio.default_out_queue = QETH_DEFAULT_QUEUE;
-	} else if (!strcmp(tmp, "prio_queueing_tos")) {
+	} else if (sysfs_streq(buf, "prio_queueing_tos")) {
 		card->qdio.do_prio_queueing = QETH_PRIO_Q_ING_TOS;
 		card->qdio.default_out_queue = QETH_DEFAULT_QUEUE;
-	} else if (!strcmp(tmp, "prio_queueing_vlan")) {
+	} else if (sysfs_streq(buf, "prio_queueing_vlan")) {
 		if (!card->options.layer2) {
 			rc = -ENOTSUPP;
 			goto out;
 		}
 		card->qdio.do_prio_queueing = QETH_PRIO_Q_ING_VLAN;
 		card->qdio.default_out_queue = QETH_DEFAULT_QUEUE;
-	} else if (!strcmp(tmp, "no_prio_queueing:0")) {
+	} else if (sysfs_streq(buf, "no_prio_queueing:0")) {
 		card->qdio.do_prio_queueing = QETH_NO_PRIO_QUEUEING;
 		card->qdio.default_out_queue = 0;
-	} else if (!strcmp(tmp, "no_prio_queueing:1")) {
+	} else if (sysfs_streq(buf, "no_prio_queueing:1")) {
 		card->qdio.do_prio_queueing = QETH_NO_PRIO_QUEUEING;
 		card->qdio.default_out_queue = 1;
-	} else if (!strcmp(tmp, "no_prio_queueing:2")) {
+	} else if (sysfs_streq(buf, "no_prio_queueing:2")) {
 		card->qdio.do_prio_queueing = QETH_NO_PRIO_QUEUEING;
 		card->qdio.default_out_queue = 2;
-	} else if (!strcmp(tmp, "no_prio_queueing:3")) {
+	} else if (sysfs_streq(buf, "no_prio_queueing:3")) {
 		card->qdio.do_prio_queueing = QETH_NO_PRIO_QUEUEING;
 		card->qdio.default_out_queue = 3;
-	} else if (!strcmp(tmp, "no_prio_queueing")) {
+	} else if (sysfs_streq(buf, "no_prio_queueing")) {
 		card->qdio.do_prio_queueing = QETH_NO_PRIO_QUEUEING;
 		card->qdio.default_out_queue = QETH_DEFAULT_QUEUE;
 	} else
@@ -497,8 +495,6 @@ static ssize_t qeth_dev_isolation_store(struct device *dev,
 	struct qeth_card *card = dev_get_drvdata(dev);
 	enum qeth_ipa_isolation_modes isolation;
 	int rc = 0;
-	char *tmp, *curtoken;
-	curtoken = (char *) buf;
 
 	if (!card)
 		return -EINVAL;
@@ -515,12 +511,11 @@ static ssize_t qeth_dev_isolation_store(struct device *dev,
 	}
 
 	/* parse input into isolation mode */
-	tmp = strsep(&curtoken, "\n");
-	if (!strcmp(tmp, ATTR_QETH_ISOLATION_NONE)) {
+	if (sysfs_streq(buf, ATTR_QETH_ISOLATION_NONE)) {
 		isolation = ISOLATION_MODE_NONE;
-	} else if (!strcmp(tmp, ATTR_QETH_ISOLATION_FWD)) {
+	} else if (sysfs_streq(buf, ATTR_QETH_ISOLATION_FWD)) {
 		isolation = ISOLATION_MODE_FWD;
-	} else if (!strcmp(tmp, ATTR_QETH_ISOLATION_DROP)) {
+	} else if (sysfs_streq(buf, ATTR_QETH_ISOLATION_DROP)) {
 		isolation = ISOLATION_MODE_DROP;
 	} else {
 		rc = -EINVAL;
@@ -597,9 +592,7 @@ static ssize_t qeth_hw_trap_store(struct device *dev,
 {
 	struct qeth_card *card = dev_get_drvdata(dev);
 	int rc = 0;
-	char *tmp, *curtoken;
 	int state = 0;
-	curtoken = (char *)buf;
 
 	if (!card)
 		return -EINVAL;
@@ -607,9 +600,8 @@ static ssize_t qeth_hw_trap_store(struct device *dev,
 	mutex_lock(&card->conf_mutex);
 	if (qeth_card_hw_is_reachable(card))
 		state = 1;
-	tmp = strsep(&curtoken, "\n");
 
-	if (!strcmp(tmp, "arm") && !card->info.hwtrap) {
+	if (sysfs_streq(buf, "arm") && !card->info.hwtrap) {
 		if (state) {
 			if (qeth_is_diagass_supported(card,
 			    QETH_DIAGS_CMD_TRAP)) {
@@ -620,14 +612,14 @@ static ssize_t qeth_hw_trap_store(struct device *dev,
 				rc = -EINVAL;
 		} else
 			card->info.hwtrap = 1;
-	} else if (!strcmp(tmp, "disarm") && card->info.hwtrap) {
+	} else if (sysfs_streq(buf, "disarm") && card->info.hwtrap) {
 		if (state) {
 			rc = qeth_hw_trap(card, QETH_DIAGS_TRAP_DISARM);
 			if (!rc)
 				card->info.hwtrap = 0;
 		} else
 			card->info.hwtrap = 0;
-	} else if (!strcmp(tmp, "trap") && state && card->info.hwtrap)
+	} else if (sysfs_streq(buf, "trap") && state && card->info.hwtrap)
 		rc = qeth_hw_trap(card, QETH_DIAGS_TRAP_CAPTURE);
 	else
 		rc = -EINVAL;
diff --git a/drivers/s390/net/qeth_l3_sys.c b/drivers/s390/net/qeth_l3_sys.c
index c4dcd66..386eb7b 100644
--- a/drivers/s390/net/qeth_l3_sys.c
+++ b/drivers/s390/net/qeth_l3_sys.c
@@ -57,22 +57,20 @@ static ssize_t qeth_l3_dev_route_store(struct qeth_card *card,
 		const char *buf, size_t count)
 {
 	enum qeth_routing_types old_route_type = route->type;
-	char *tmp;
 	int rc = 0;
 
-	tmp = strsep((char **) &buf, "\n");
 	mutex_lock(&card->conf_mutex);
-	if (!strcmp(tmp, "no_router")) {
+	if (sysfs_streq(buf, "no_router")) {
 		route->type = NO_ROUTER;
-	} else if (!strcmp(tmp, "primary_connector")) {
+	} else if (sysfs_streq(buf, "primary_connector")) {
 		route->type = PRIMARY_CONNECTOR;
-	} else if (!strcmp(tmp, "secondary_connector")) {
+	} else if (sysfs_streq(buf, "secondary_connector")) {
 		route->type = SECONDARY_CONNECTOR;
-	} else if (!strcmp(tmp, "primary_router")) {
+	} else if (sysfs_streq(buf, "primary_router")) {
 		route->type = PRIMARY_ROUTER;
-	} else if (!strcmp(tmp, "secondary_router")) {
+	} else if (sysfs_streq(buf, "secondary_router")) {
 		route->type = SECONDARY_ROUTER;
-	} else if (!strcmp(tmp, "multicast_router")) {
+	} else if (sysfs_streq(buf, "multicast_router")) {
 		route->type = MULTICAST_ROUTER;
 	} else {
 		rc = -EINVAL;
@@ -370,7 +368,6 @@ static ssize_t qeth_l3_dev_ipato_enable_store(struct device *dev,
 {
 	struct qeth_card *card = dev_get_drvdata(dev);
 	struct qeth_ipaddr *tmpipa, *t;
-	char *tmp;
 	int rc = 0;
 
 	if (!card)
@@ -383,10 +380,9 @@ static ssize_t qeth_l3_dev_ipato_enable_store(struct device *dev,
 		goto out;
 	}
 
-	tmp = strsep((char **) &buf, "\n");
-	if (!strcmp(tmp, "toggle")) {
+	if (sysfs_streq(buf, "toggle")) {
 		card->ipato.enabled = (card->ipato.enabled)? 0 : 1;
-	} else if (!strcmp(tmp, "1")) {
+	} else if (sysfs_streq(buf, "1")) {
 		card->ipato.enabled = 1;
 		list_for_each_entry_safe(tmpipa, t, card->ip_tbd_list, entry) {
 			if ((tmpipa->type == QETH_IP_TYPE_NORMAL) &&
@@ -395,7 +391,7 @@ static ssize_t qeth_l3_dev_ipato_enable_store(struct device *dev,
 					QETH_IPA_SETIP_TAKEOVER_FLAG;
 		}
 
-	} else if (!strcmp(tmp, "0")) {
+	} else if (sysfs_streq(buf, "0")) {
 		card->ipato.enabled = 0;
 		list_for_each_entry_safe(tmpipa, t, card->ip_tbd_list, entry) {
 			if (tmpipa->set_flags &
@@ -430,21 +426,19 @@ static ssize_t qeth_l3_dev_ipato_invert4_store(struct device *dev,
 				const char *buf, size_t count)
 {
 	struct qeth_card *card = dev_get_drvdata(dev);
-	char *tmp;
 	int rc = 0;
 
 	if (!card)
 		return -EINVAL;
 
 	mutex_lock(&card->conf_mutex);
-	tmp = strsep((char **) &buf, "\n");
-	if (!strcmp(tmp, "toggle")) {
+	if (sysfs_streq(buf, "toggle"))
 		card->ipato.invert4 = (card->ipato.invert4)? 0 : 1;
-	} else if (!strcmp(tmp, "1")) {
+	else if (sysfs_streq(buf, "1"))
 		card->ipato.invert4 = 1;
-	} else if (!strcmp(tmp, "0")) {
+	else if (sysfs_streq(buf, "0"))
 		card->ipato.invert4 = 0;
-	} else
+	else
 		rc = -EINVAL;
 	mutex_unlock(&card->conf_mutex);
 	return rc ? rc : count;
@@ -612,21 +606,19 @@ static ssize_t qeth_l3_dev_ipato_invert6_store(struct device *dev,
 		struct device_attribute *attr, const char *buf, size_t count)
 {
 	struct qeth_card *card = dev_get_drvdata(dev);
-	char *tmp;
 	int rc = 0;
 
 	if (!card)
 		return -EINVAL;
 
 	mutex_lock(&card->conf_mutex);
-	tmp = strsep((char **) &buf, "\n");
-	if (!strcmp(tmp, "toggle")) {
+	if (sysfs_streq(buf, "toggle"))
 		card->ipato.invert6 = (card->ipato.invert6)? 0 : 1;
-	} else if (!strcmp(tmp, "1")) {
+	else if (sysfs_streq(buf, "1"))
 		card->ipato.invert6 = 1;
-	} else if (!strcmp(tmp, "0")) {
+	else if (sysfs_streq(buf, "0"))
 		card->ipato.invert6 = 0;
-	} else
+	else
 		rc = -EINVAL;
 	mutex_unlock(&card->conf_mutex);
 	return rc ? rc : count;
-- 
2.1.4
