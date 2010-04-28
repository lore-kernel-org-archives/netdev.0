From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 2/7] caif: Rename functions in cfcnfg and caif_dev
Date: Wed, 28 Apr 2010 20:54:35 +0200
Message-ID: <1272480880-30672-2-git-send-email-sjur.brandeland@stericsson.com>
References: <1272480880-30672-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: marcel@holtmann.org, daniel.martensson@stericsson.com,
	sjurbr@gmail.com, linus.walleij@stericsson.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eterpe-smout.broadpark.no ([80.202.8.16]:35420 "EHLO
	eterpe-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756544Ab0D1SzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 14:55:25 -0400
Received: from ignis-smin.broadpark.no ([unknown] [80.202.8.11])
 by eterpe-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L1L00K2EOK6DG80@eterpe-smout.broadpark.no> for
 netdev@vger.kernel.org; Wed, 28 Apr 2010 20:55:18 +0200 (CEST)
Received: from localhost.localdomain ([unknown] [84.49.77.207])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L1L00MYUOK4Q560@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Wed, 28 Apr 2010 20:55:18 +0200 (CEST)
In-reply-to: <1272480880-30672-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Changes:
 o Renamed cfcnfg_del_adapt_layer to cfcnfg_disconn_adapt_layer
 o Fixed typo cfcfg to cfcnfg
 o Renamed linkid to channel_id
 o Updated documentation in caif_dev.h
 o Minor formatting changes

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 include/net/caif/caif_dev.h |    6 +++-
 include/net/caif/cfcnfg.h   |   10 ++++----
 net/caif/caif_dev.c         |   15 ++++++------
 net/caif/cfcnfg.c           |   51 +++++++++++++++++++++----------------------
 4 files changed, 41 insertions(+), 41 deletions(-)

diff --git a/include/net/caif/caif_dev.h b/include/net/caif/caif_dev.h
index 42a7c78..3aa1ff6 100644
--- a/include/net/caif/caif_dev.h
+++ b/include/net/caif/caif_dev.h
@@ -23,17 +23,19 @@ struct caif_param {
 };
 
 /**
- * caif_connect_request - Request data for CAIF channel setup.
+ * struct caif_connect_request - Request data for CAIF channel setup.
+ * @protocol:		Type of CAIF protocol to use (at, datagram etc)
  * @sockaddr:		Socket address to connect.
  * @priority:		Priority of the connection.
  * @link_selector:	Link selector (high bandwidth or low latency)
  * @link_name:		Name of the CAIF Link Layer to use.
+ * @param:		Connect Request parameters (CAIF_SO_REQ_PARAM).
  *
  * This struct is used when connecting a CAIF channel.
  * It contains all CAIF channel configuration options.
  */
 struct caif_connect_request {
-	int protocol;
+	enum caif_protocol_type protocol;
 	struct sockaddr_caif sockaddr;
 	enum caif_channel_priority priority;
 	enum caif_link_selector link_selector;
diff --git a/include/net/caif/cfcnfg.h b/include/net/caif/cfcnfg.h
index 366082c..f16b875 100644
--- a/include/net/caif/cfcnfg.h
+++ b/include/net/caif/cfcnfg.h
@@ -87,13 +87,14 @@ cfcnfg_add_phy_layer(struct cfcnfg *cnfg, enum cfcnfg_phy_type phy_type,
 int cfcnfg_del_phy_layer(struct cfcnfg *cnfg, struct cflayer *phy_layer);
 
 /**
- * cfcnfg_del_adapt_layer - Deletes an adaptation layer from the CAIF stack.
+ * cfcnfg_disconn_adapt_layer - Disconnects an adaptation layer.
  *
  * @cnfg:	Pointer to a CAIF configuration object, created by
  *		cfcnfg_create().
  * @adap_layer: Adaptation layer to be removed.
  */
-int cfcnfg_del_adapt_layer(struct cfcnfg *cnfg, struct cflayer *adap_layer);
+int cfcnfg_disconn_adapt_layer(struct cfcnfg *cnfg,
+			struct cflayer *adap_layer);
 
 /**
  * cfcnfg_add_adaptation_layer - Add an adaptation layer to the CAIF stack.
@@ -102,14 +103,13 @@ int cfcnfg_del_adapt_layer(struct cfcnfg *cnfg, struct cflayer *adap_layer);
  * driver functionality is implemented.
  *
  * @cnfg:		Pointer to a CAIF configuration object, created by
- *				cfcnfg_create().
+ *			cfcnfg_create().
  * @param:		Link setup parameters.
  * @adap_layer:		Specify the adaptation layer; the receive and
  *			flow-control functions MUST be set in the structure.
  *
  */
-int
-cfcnfg_add_adaptation_layer(struct cfcnfg *cnfg,
+int cfcnfg_add_adaptation_layer(struct cfcnfg *cnfg,
 			    struct cfctrl_link_param *param,
 			    struct cflayer *adap_layer);
 
diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index e84837e..be1f674 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -330,20 +330,19 @@ int caif_connect_client(struct caif_connect_request *conn_req,
 			   struct cflayer *client_layer)
 {
 	struct cfctrl_link_param param;
-	if (connect_req_to_link_param(get_caif_conf(), conn_req, &param) == 0)
-		/* Hook up the adaptation layer. */
-		return cfcnfg_add_adaptation_layer(get_caif_conf(),
+	int ret;
+	ret = connect_req_to_link_param(get_caif_conf(), conn_req, &param);
+	if (ret)
+		return ret;
+	/* Hook up the adaptation layer. */
+	return cfcnfg_add_adaptation_layer(get_caif_conf(),
 						&param, client_layer);
-
-	return -EINVAL;
-
-	caif_assert(0);
 }
 EXPORT_SYMBOL(caif_connect_client);
 
 int caif_disconnect_client(struct cflayer *adap_layer)
 {
-	return cfcnfg_del_adapt_layer(get_caif_conf(), adap_layer);
+       return cfcnfg_disconn_adapt_layer(get_caif_conf(), adap_layer);
 }
 EXPORT_SYMBOL(caif_disconnect_client);
 
diff --git a/net/caif/cfcnfg.c b/net/caif/cfcnfg.c
index c873e3d..d52f256 100644
--- a/net/caif/cfcnfg.c
+++ b/net/caif/cfcnfg.c
@@ -51,12 +51,12 @@ struct cfcnfg {
 	struct cfcnfg_phyinfo phy_layers[MAX_PHY_LAYERS];
 };
 
-static void cncfg_linkup_rsp(struct cflayer *layer, u8 linkid,
+static void cfcnfg_linkup_rsp(struct cflayer *layer, u8 channel_id,
 			     enum cfctrl_srv serv, u8 phyid,
 			     struct cflayer *adapt_layer);
-static void cncfg_linkdestroy_rsp(struct cflayer *layer, u8 linkid,
+static void cfcnfg_linkdestroy_rsp(struct cflayer *layer, u8 channel_id,
 				  struct cflayer *client_layer);
-static void cncfg_reject_rsp(struct cflayer *layer, u8 linkid,
+static void cfcnfg_reject_rsp(struct cflayer *layer, u8 channel_id,
 			     struct cflayer *adapt_layer);
 static void cfctrl_resp_func(void);
 static void cfctrl_enum_resp(void);
@@ -82,13 +82,13 @@ struct cfcnfg *cfcnfg_create(void)
 	resp = cfctrl_get_respfuncs(this->ctrl);
 	resp->enum_rsp = cfctrl_enum_resp;
 	resp->linkerror_ind = cfctrl_resp_func;
-	resp->linkdestroy_rsp = cncfg_linkdestroy_rsp;
+	resp->linkdestroy_rsp = cfcnfg_linkdestroy_rsp;
 	resp->sleep_rsp = cfctrl_resp_func;
 	resp->wake_rsp = cfctrl_resp_func;
 	resp->restart_rsp = cfctrl_resp_func;
 	resp->radioset_rsp = cfctrl_resp_func;
-	resp->linksetup_rsp = cncfg_linkup_rsp;
-	resp->reject_rsp = cncfg_reject_rsp;
+	resp->linksetup_rsp = cfcnfg_linkup_rsp;
+	resp->reject_rsp = cfcnfg_reject_rsp;
 
 	this->last_phyid = 1;
 
@@ -191,8 +191,7 @@ int cfcnfg_get_named(struct cfcnfg *cnfg, char *name)
  *	 4) Link-Error - (no response)
  *	      Not handled, but this should be a CAIF PROTOCOL ERROR
  */
-
-int cfcnfg_del_adapt_layer(struct cfcnfg *cnfg, struct cflayer *adap_layer)
+int cfcnfg_disconn_adapt_layer(struct cfcnfg *cnfg, struct cflayer *adap_layer)
 {
 	u8 channel_id = 0;
 	int ret = 0;
@@ -246,9 +245,9 @@ end:
 	return ret;
 
 }
-EXPORT_SYMBOL(cfcnfg_del_adapt_layer);
+EXPORT_SYMBOL(cfcnfg_disconn_adapt_layer);
 
-static void cncfg_linkdestroy_rsp(struct cflayer *layer, u8 linkid,
+static void cfcnfg_linkdestroy_rsp(struct cflayer *layer, u8 channel_id,
 				  struct cflayer *client_layer)
 {
 	struct cfcnfg *cnfg = container_obj(layer);
@@ -258,20 +257,20 @@ static void cncfg_linkdestroy_rsp(struct cflayer *layer, u8 linkid,
 	 * 1) Remove service from the MUX layer. The MUX must
 	 *    guarante that no more payload sent "upwards" (receive)
 	 */
-	servl = cfmuxl_remove_uplayer(cnfg->mux, linkid);
+	servl = cfmuxl_remove_uplayer(cnfg->mux, channel_id);
 
 	if (servl == NULL) {
 		pr_err("CAIF: %s(): PROTOCOL ERROR "
-		       "- Error removing service_layer Linkid(%d)",
-			__func__, linkid);
+		       "- Error removing service_layer Channel_Id(%d)",
+			__func__, channel_id);
 		return;
 	}
-	caif_assert(linkid == servl->id);
+	caif_assert(channel_id == servl->id);
 
 	if (servl != client_layer && servl->up != client_layer) {
 		pr_err("CAIF: %s(): Error removing service_layer "
-		       "Linkid(%d) %p %p",
-			__func__, linkid, (void *) servl,
+		       "Channel_Id(%d) %p %p",
+			__func__, channel_id, (void *) servl,
 			(void *) client_layer);
 		return;
 	}
@@ -345,7 +344,7 @@ cfcnfg_add_adaptation_layer(struct cfcnfg *cnfg,
 }
 EXPORT_SYMBOL(cfcnfg_add_adaptation_layer);
 
-static void cncfg_reject_rsp(struct cflayer *layer, u8 linkid,
+static void cfcnfg_reject_rsp(struct cflayer *layer, u8 channel_id,
 			     struct cflayer *adapt_layer)
 {
 	if (adapt_layer != NULL && adapt_layer->ctrlcmd != NULL)
@@ -354,7 +353,7 @@ static void cncfg_reject_rsp(struct cflayer *layer, u8 linkid,
 }
 
 static void
-cncfg_linkup_rsp(struct cflayer *layer, u8 linkid, enum cfctrl_srv serv,
+cfcnfg_linkup_rsp(struct cflayer *layer, u8 channel_id, enum cfctrl_srv serv,
 		 u8 phyid, struct cflayer *adapt_layer)
 {
 	struct cfcnfg *cnfg = container_obj(layer);
@@ -383,26 +382,26 @@ cncfg_linkup_rsp(struct cflayer *layer, u8 linkid, enum cfctrl_srv serv,
 					     _CAIF_MODEMCMD_PHYIF_USEFULL);
 
 	}
-	adapt_layer->id = linkid;
+	adapt_layer->id = channel_id;
 
 	switch (serv) {
 	case CFCTRL_SRV_VEI:
-		servicel = cfvei_create(linkid, &phyinfo->dev_info);
+		servicel = cfvei_create(channel_id, &phyinfo->dev_info);
 		break;
 	case CFCTRL_SRV_DATAGRAM:
-		servicel = cfdgml_create(linkid, &phyinfo->dev_info);
+		servicel = cfdgml_create(channel_id, &phyinfo->dev_info);
 		break;
 	case CFCTRL_SRV_RFM:
-		servicel = cfrfml_create(linkid, &phyinfo->dev_info);
+		servicel = cfrfml_create(channel_id, &phyinfo->dev_info);
 		break;
 	case CFCTRL_SRV_UTIL:
-		servicel = cfutill_create(linkid, &phyinfo->dev_info);
+		servicel = cfutill_create(channel_id, &phyinfo->dev_info);
 		break;
 	case CFCTRL_SRV_VIDEO:
-		servicel = cfvidl_create(linkid, &phyinfo->dev_info);
+		servicel = cfvidl_create(channel_id, &phyinfo->dev_info);
 		break;
 	case CFCTRL_SRV_DBG:
-		servicel = cfdbgl_create(linkid, &phyinfo->dev_info);
+		servicel = cfdbgl_create(channel_id, &phyinfo->dev_info);
 		break;
 	default:
 		pr_err("CAIF: %s(): Protocol error. "
@@ -415,7 +414,7 @@ cncfg_linkup_rsp(struct cflayer *layer, u8 linkid, enum cfctrl_srv serv,
 		return;
 	}
 	layer_set_dn(servicel, cnfg->mux);
-	cfmuxl_set_uplayer(cnfg->mux, servicel, linkid);
+	cfmuxl_set_uplayer(cnfg->mux, servicel, channel_id);
 	layer_set_up(servicel, adapt_layer);
 	layer_set_dn(adapt_layer, servicel);
 	servicel->ctrlcmd(servicel, CAIF_CTRLCMD_INIT_RSP, 0);
-- 
1.6.3.3

