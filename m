From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] prism54 tree sync update
Date: Wed, 17 Mar 2004 04:49:17 -0500
Sender: prism54-devel-admin@prism54.org
Message-ID: <40581F1D.5090704@pobox.com>
References: <20040317063659.GC24063@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050609010905000107010904"
Cc: netdev@oss.sgi.com, prism54-devel@prism54.org
Return-path: <prism54-devel-admin@prism54.org>
To: "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>
In-Reply-To: <20040317063659.GC24063@ruslug.rutgers.edu>
Errors-To: prism54-devel-admin@prism54.org
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Post: <mailto:prism54-devel@prism54.org>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel/>
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050609010905000107010904
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Luis R. Rodriguez wrote:
> Attached patch has been well tested. It updates 2.6.5-rc1 prism54
> sources to our latest work (which had also previously been tested).
> Some additional new kernel updates were integrated as well.

Applied to 2.6, after splitting up into the two attached patches.

Please double-check that no changes were missed, and send a patch 
incremental to the attachments if so.

	Jeff



--------------050609010905000107010904
Content-Type: text/plain;
 name="patch-a"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-a"

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1739  -> 1.1740 
#	drivers/net/wireless/prism54/islpci_dev.c	1.3     -> 1.4    
#	drivers/net/wireless/prism54/islpci_eth.c	1.2     -> 1.3    
#	drivers/net/wireless/prism54/isl_ioctl.c	1.3     -> 1.4    
#	drivers/net/wireless/prism54/islpci_hotplug.c	1.2     -> 1.3    
#	drivers/net/wireless/prism54/islpci_mgt.c	1.3     -> 1.4    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/03/17	mcgrof@studorgs.rutgers.edu	1.1740
# [wireless prism54] use netdev_priv() helper
# --------------------------------------------
#
diff -Nru a/drivers/net/wireless/prism54/isl_ioctl.c b/drivers/net/wireless/prism54/isl_ioctl.c
--- a/drivers/net/wireless/prism54/isl_ioctl.c	Wed Mar 17 04:47:27 2004
+++ b/drivers/net/wireless/prism54/isl_ioctl.c	Wed Mar 17 04:47:27 2004
@@ -250,7 +250,7 @@
 struct iw_statistics *
 prism54_get_wireless_stats(struct net_device *ndev)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 
 	/* If the stats are being updated return old data */
 	if (down_trylock(&priv->stats_sem) == 0) {
@@ -277,7 +277,7 @@
 prism54_commit(struct net_device *ndev, struct iw_request_info *info,
 	       char *cwrq, char *extra)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 
 	/* simply re-set the last set SSID, this should commit most stuff */
 
@@ -293,7 +293,7 @@
 prism54_get_name(struct net_device *ndev, struct iw_request_info *info,
 		 char *cwrq, char *extra)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 	char *capabilities;
 	union oid_res_t r;
 	int rvalue;
@@ -324,7 +324,7 @@
 prism54_set_freq(struct net_device *ndev, struct iw_request_info *info,
 		 struct iw_freq *fwrq, char *extra)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 	int rvalue;
 	u32 c = 0;
 
@@ -363,7 +363,7 @@
 prism54_get_freq(struct net_device *ndev, struct iw_request_info *info,
 		 struct iw_freq *fwrq, char *extra)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 	union oid_res_t r;
 	int rvalue;
 
@@ -379,7 +379,7 @@
 prism54_set_mode(struct net_device *ndev, struct iw_request_info *info,
 		 __u32 * uwrq, char *extra)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 	u32 mlmeautolevel = CARD_DEFAULT_MLME_MODE;
 
 	/* Let's see if the user passed a valid Linux Wireless mode */
@@ -420,7 +420,7 @@
 prism54_get_mode(struct net_device *ndev, struct iw_request_info *info,
 		 __u32 * uwrq, char *extra)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 
 	BUG_ON((priv->iw_mode < IW_MODE_AUTO) || (priv->iw_mode >
 						  IW_MODE_MONITOR));
@@ -438,7 +438,7 @@
 prism54_set_sens(struct net_device *ndev, struct iw_request_info *info,
 		 struct iw_param *vwrq, char *extra)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 	u32 sens;
 
 	/* by default  the card sets this to 20. */
@@ -452,7 +452,7 @@
 prism54_get_sens(struct net_device *ndev, struct iw_request_info *info,
 		 struct iw_param *vwrq, char *extra)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 	union oid_res_t r;
 	int rvalue;
 
@@ -470,7 +470,7 @@
 		  struct iw_point *dwrq, char *extra)
 {
 	struct iw_range *range = (struct iw_range *) extra;
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 	char *data;
 	int i, m, rvalue;
 	struct obj_frequencies *freq;
@@ -576,7 +576,7 @@
 prism54_set_wap(struct net_device *ndev, struct iw_request_info *info,
 		struct sockaddr *awrq, char *extra)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 	char bssid[6];
 	int rvalue;
 
@@ -598,7 +598,7 @@
 prism54_get_wap(struct net_device *ndev, struct iw_request_info *info,
 		struct sockaddr *awrq, char *extra)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 	union oid_res_t r;
 	int rvalue;
 
@@ -630,7 +630,7 @@
 {
 	struct iw_event iwe;	/* Temporary buffer */
 	short cap;
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 
 	/* The first entry must be the MAC address */
 	memcpy(iwe.u.ap_addr.sa_data, bss->address, 6);
@@ -721,7 +721,7 @@
 prism54_get_scan(struct net_device *ndev, struct iw_request_info *info,
 		 struct iw_point *dwrq, char *extra)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 	int i, rvalue;
 	struct obj_bsslist *bsslist;
 	u32 noise = 0;
@@ -762,7 +762,7 @@
 prism54_set_essid(struct net_device *ndev, struct iw_request_info *info,
 		  struct iw_point *dwrq, char *extra)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 	struct obj_ssid essid;
 
 	memset(essid.octets, 0, 33);
@@ -789,7 +789,7 @@
 prism54_get_essid(struct net_device *ndev, struct iw_request_info *info,
 		  struct iw_point *dwrq, char *extra)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 	struct obj_ssid *essid;
 	union oid_res_t r;
 	int rvalue;
@@ -819,7 +819,7 @@
 prism54_set_nick(struct net_device *ndev, struct iw_request_info *info,
 		 struct iw_point *dwrq, char *extra)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 
 	if (dwrq->length > IW_ESSID_MAX_SIZE)
 		return -E2BIG;
@@ -836,7 +836,7 @@
 prism54_get_nick(struct net_device *ndev, struct iw_request_info *info,
 		 struct iw_point *dwrq, char *extra)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 
 	dwrq->length = 0;
 
@@ -856,7 +856,7 @@
 		 struct iw_param *vwrq, char *extra)
 {
 
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 	u32 rate, profile;
 	char *data;
 	int ret, i;
@@ -924,7 +924,7 @@
 		 struct iw_request_info *info,
 		 struct iw_param *vwrq, char *extra)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 	int rvalue;
 	char *data;
 	union oid_res_t r;
@@ -948,7 +948,7 @@
 prism54_set_rts(struct net_device *ndev, struct iw_request_info *info,
 		struct iw_param *vwrq, char *extra)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 
 	return mgt_set_request(priv, DOT11_OID_RTSTHRESH, 0, &vwrq->value);
 }
@@ -957,7 +957,7 @@
 prism54_get_rts(struct net_device *ndev, struct iw_request_info *info,
 		struct iw_param *vwrq, char *extra)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 	union oid_res_t r;
 	int rvalue;
 
@@ -972,7 +972,7 @@
 prism54_set_frag(struct net_device *ndev, struct iw_request_info *info,
 		 struct iw_param *vwrq, char *extra)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 
 	return mgt_set_request(priv, DOT11_OID_FRAGTHRESH, 0, &vwrq->value);
 }
@@ -981,7 +981,7 @@
 prism54_get_frag(struct net_device *ndev, struct iw_request_info *info,
 		 struct iw_param *vwrq, char *extra)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 	union oid_res_t r;
 	int rvalue;
 
@@ -1004,7 +1004,7 @@
 prism54_set_retry(struct net_device *ndev, struct iw_request_info *info,
 		  struct iw_param *vwrq, char *extra)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 	u32 slimit = 0, llimit = 0;	/* short and long limit */
 	u32 lifetime = 0;
 	int rvalue = 0;
@@ -1048,7 +1048,7 @@
 prism54_get_retry(struct net_device *ndev, struct iw_request_info *info,
 		  struct iw_param *vwrq, char *extra)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 	union oid_res_t r;
 	int rvalue = 0;
 	vwrq->disabled = 0;	/* It cannot be disabled */
@@ -1080,7 +1080,7 @@
 prism54_set_encode(struct net_device *ndev, struct iw_request_info *info,
 		   struct iw_point *dwrq, char *extra)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 	int rvalue = 0, force = 0;
 	int authen = DOT11_AUTH_OS, invoke = 0, exunencrypt = 0;
 	union oid_res_t r;
@@ -1170,7 +1170,7 @@
 prism54_get_encode(struct net_device *ndev, struct iw_request_info *info,
 		   struct iw_point *dwrq, char *extra)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 	struct obj_key *key;
 	u32 devindex, index = (dwrq->flags & IW_ENCODE_INDEX) - 1;
 	u32 authen = 0, invoke = 0, exunencrypt = 0;
@@ -1218,7 +1218,7 @@
 prism54_get_txpower(struct net_device *ndev, struct iw_request_info *info,
 		    struct iw_param *vwrq, char *extra)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 	union oid_res_t r;
 	int rvalue;
 
@@ -1238,7 +1238,7 @@
 prism54_set_txpower(struct net_device *ndev, struct iw_request_info *info,
 		    struct iw_param *vwrq, char *extra)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 	s32 u = vwrq->value;
 
 	/* intersil firmware operates in 0.25 dBm (1/4) */
@@ -1264,7 +1264,7 @@
 prism54_reset(struct net_device *ndev, struct iw_request_info *info,
 	      __u32 * uwrq, char *extra)
 {
-	islpci_reset(ndev->priv, 0);
+	islpci_reset(netdev_priv(ndev), 0);
 
 	return 0;
 }
@@ -1273,7 +1273,7 @@
 prism54_set_beacon(struct net_device *ndev, struct iw_request_info *info,
 		   __u32 * uwrq, char *extra)
 {
-	int rvalue = mgt_set_request((islpci_private *) ndev->priv,
+	int rvalue = mgt_set_request((islpci_private *) netdev_priv(ndev),
 				     DOT11_OID_BEACONPERIOD, 0, uwrq);
 
 	return (rvalue ? rvalue : -EINPROGRESS);
@@ -1287,7 +1287,7 @@
 	int rvalue;
 
 	rvalue =
-	    mgt_get_request((islpci_private *) ndev->priv,
+	    mgt_get_request((islpci_private *) netdev_priv(ndev),
 			    DOT11_OID_BEACONPERIOD, 0, NULL, &r);
 	*uwrq = r.u;
 
@@ -1337,7 +1337,7 @@
 prism54_add_mac(struct net_device *ndev, struct iw_request_info *info,
 		struct sockaddr *awrq, char *extra)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 	struct islpci_acl *acl = &priv->acl;
 	struct mac_entry *entry;
 	struct sockaddr *addr = (struct sockaddr *) extra;
@@ -1366,7 +1366,7 @@
 prism54_del_mac(struct net_device *ndev, struct iw_request_info *info,
 		struct sockaddr *awrq, char *extra)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 	struct islpci_acl *acl = &priv->acl;
 	struct mac_entry *entry;
 	struct list_head *ptr;
@@ -1396,7 +1396,7 @@
 prism54_get_mac(struct net_device *ndev, struct iw_request_info *info,
 		struct iw_point *dwrq, char *extra)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 	struct islpci_acl *acl = &priv->acl;
 	struct mac_entry *entry;
 	struct list_head *ptr;
@@ -1427,7 +1427,7 @@
 prism54_set_policy(struct net_device *ndev, struct iw_request_info *info,
 		   __u32 * uwrq, char *extra)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 	struct islpci_acl *acl = &priv->acl;
 	u32 mlmeautolevel;
 
@@ -1460,7 +1460,7 @@
 prism54_get_policy(struct net_device *ndev, struct iw_request_info *info,
 		   __u32 * uwrq, char *extra)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 	struct islpci_acl *acl = &priv->acl;
 
 	*uwrq = acl->policy;
@@ -1511,7 +1511,7 @@
 
 	/* Tell the card to kick every client */
 	mlme->id = cpu_to_le16(0);
-	rvalue = mgt_set_request(ndev->priv, DOT11_OID_DISASSOCIATE, 0, mlme);
+	rvalue = mgt_set_request(netdev_priv(ndev), DOT11_OID_DISASSOCIATE, 0, mlme);
 	kfree(mlme);
 
 	return rvalue;
@@ -1535,7 +1535,7 @@
 	/* Tell the card to only kick the corresponding bastard */
 	memcpy(mlme->address, addr->sa_data, ETH_ALEN);
 	mlme->id = cpu_to_le16(-1);
-	rvalue = mgt_set_request(ndev->priv, DOT11_OID_DISASSOCIATE, 0, mlme);
+	rvalue = mgt_set_request(netdev_priv(ndev), DOT11_OID_DISASSOCIATE, 0, mlme);
 
 	kfree(mlme);
 
@@ -1595,7 +1595,7 @@
 static void
 link_changed(struct net_device *ndev, u32 bitrate)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 
 	if (le32_to_cpu(bitrate)) {
 		if (priv->iw_mode == IW_MODE_INFRA) {
@@ -1604,9 +1604,9 @@
 					NULL);
 			wireless_send_event(ndev, SIOCGIWAP, &uwrq, NULL);
 		} else
-			send_simple_event(ndev->priv, "Link established");
+			send_simple_event(netdev_priv(ndev), "Link established");
 	} else
-		send_simple_event(ndev->priv, "Link lost");
+		send_simple_event(netdev_priv(ndev), "Link lost");
 }
 
 /* Beacon/ProbeResp payload header */
@@ -1889,16 +1889,17 @@
 prism54_process_trap(void *data)
 {
 	struct islpci_mgmtframe *frame = data;
+	struct net_device *ndev = frame->ndev;
 	enum oid_num_t n = mgt_oidtonum(frame->header->oid);
 
-	prism54_process_trap_helper(frame->ndev->priv, n, frame->data);
+	prism54_process_trap_helper(netdev_priv(ndev), n, frame->data);
 	islpci_mgt_release(frame);
 }
 
 int
 prism54_set_mac_address(struct net_device *ndev, void *addr)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 	int ret;
 
 	if (ndev->addr_len != 6)
@@ -1923,7 +1924,7 @@
 prism54_set_wpa(struct net_device *ndev, struct iw_request_info *info,
 		__u32 * uwrq, char *extra)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 
 	down_write(&priv->mib_sem);
 
@@ -1964,7 +1965,7 @@
 prism54_get_oid(struct net_device *ndev, struct iw_request_info *info,
 		struct iw_point *data, char *extra)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 	struct islpci_mgmtframe *response = NULL;
 	int ret = -EIO, response_op = PIMFOR_OP_ERROR;
 	
@@ -1998,7 +1999,7 @@
 prism54_set_oid(struct net_device *ndev, struct iw_request_info *info,
 		struct iw_point *data, char *extra)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 	struct islpci_mgmtframe *response = NULL;
 	int ret = 0, response_op = PIMFOR_OP_ERROR;
 	
diff -Nru a/drivers/net/wireless/prism54/islpci_dev.c b/drivers/net/wireless/prism54/islpci_dev.c
--- a/drivers/net/wireless/prism54/islpci_dev.c	Wed Mar 17 04:47:27 2004
+++ b/drivers/net/wireless/prism54/islpci_dev.c	Wed Mar 17 04:47:27 2004
@@ -245,7 +245,7 @@
 islpci_open(struct net_device *ndev)
 {
 	u32 rc;
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 
 	printk(KERN_DEBUG "%s: islpci_open()\n", ndev->name);
 
@@ -265,7 +265,7 @@
 static int
 islpci_close(struct net_device *ndev)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 
 	printk(KERN_DEBUG "%s: islpci_close ()\n", ndev->name);
 
@@ -491,7 +491,7 @@
 struct net_device_stats *
 islpci_statistics(struct net_device *ndev)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 
 #if VERBOSE > SHOW_ERROR_MESSAGES
 	DEBUG(SHOW_FUNCTION_CALLS, "islpci_statistics \n");
diff -Nru a/drivers/net/wireless/prism54/islpci_eth.c b/drivers/net/wireless/prism54/islpci_eth.c
--- a/drivers/net/wireless/prism54/islpci_eth.c	Wed Mar 17 04:47:27 2004
+++ b/drivers/net/wireless/prism54/islpci_eth.c	Wed Mar 17 04:47:27 2004
@@ -72,7 +72,7 @@
 int
 islpci_eth_transmit(struct sk_buff *skb, struct net_device *ndev)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 	isl38xx_control_block *cb = priv->control_block;
 	u32 index;
 	dma_addr_t pci_map_address;
@@ -411,7 +411,7 @@
 void
 islpci_eth_tx_timeout(struct net_device *ndev)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 	struct net_device_stats *statistics = &priv->statistics;
 
 	/* increment the transmit error counter */
diff -Nru a/drivers/net/wireless/prism54/islpci_hotplug.c b/drivers/net/wireless/prism54/islpci_hotplug.c
--- a/drivers/net/wireless/prism54/islpci_hotplug.c	Wed Mar 17 04:47:27 2004
+++ b/drivers/net/wireless/prism54/islpci_hotplug.c	Wed Mar 17 04:47:27 2004
@@ -133,7 +133,7 @@
 	islpci_private	*priv;
 	char		*modelp;
 
-	priv = ndev->priv;
+	priv = netdev_priv(ndev);
 	switch (priv->pdev->subsystem_device) {
 	case PCIDEVICE_ISL3877:
 		modelp = "PRISM Indigo";
@@ -269,7 +269,7 @@
 		goto do_pci_release_regions;
 	}
 
-	priv = ndev->priv;
+	priv = netdev_priv(ndev);
 	islpci_set_state(priv, PRV_STATE_PREBOOT); /* we are attempting to boot */
 
 	/* card is in unknown state yet, might have some interrupts pending */
@@ -314,7 +314,7 @@
 prism54_remove(struct pci_dev *pdev)
 {
 	struct net_device *ndev = pci_get_drvdata(pdev);
-	islpci_private *priv = ndev ? ndev->priv : 0;
+	islpci_private *priv = ndev ? netdev_priv(ndev) : 0;
 	BUG_ON(!priv);
 
 	if (!__in_cleanup_module) {
@@ -355,7 +355,7 @@
 prism54_suspend(struct pci_dev *pdev, u32 state)
 {
 	struct net_device *ndev = pci_get_drvdata(pdev);
-	islpci_private *priv = ndev ? ndev->priv : 0;
+	islpci_private *priv = ndev ? netdev_priv(ndev) : 0;
 	BUG_ON(!priv);
 
 	printk(KERN_NOTICE "%s: got suspend request (state %d)\n",
@@ -380,7 +380,7 @@
 prism54_resume(struct pci_dev *pdev)
 {
 	struct net_device *ndev = pci_get_drvdata(pdev);
-	islpci_private *priv = ndev ? ndev->priv : 0;
+	islpci_private *priv = ndev ? netdev_priv(ndev) : 0;
 	BUG_ON(!priv);
 
 	printk(KERN_NOTICE "%s: got resume request\n", ndev->name);
diff -Nru a/drivers/net/wireless/prism54/islpci_mgt.c b/drivers/net/wireless/prism54/islpci_mgt.c
--- a/drivers/net/wireless/prism54/islpci_mgt.c	Wed Mar 17 04:47:27 2004
+++ b/drivers/net/wireless/prism54/islpci_mgt.c	Wed Mar 17 04:47:27 2004
@@ -106,7 +106,7 @@
 int
 islpci_mgmt_rx_fill(struct net_device *ndev)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 	isl38xx_control_block *cb =    /* volatile not needed */
 		(isl38xx_control_block *) priv->control_block;
 	u32 curr = le32_to_cpu(cb->driver_curr_frag[ISL38XX_CB_RX_MGMTQ]);
@@ -165,7 +165,7 @@
 islpci_mgt_transmit(struct net_device *ndev, int operation, unsigned long oid,
 		    void *data, int length)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 	isl38xx_control_block *cb =
 		(isl38xx_control_block *) priv->control_block;
 	void *p;
@@ -271,7 +271,7 @@
 int
 islpci_mgt_receive(struct net_device *ndev)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 	isl38xx_control_block *cb =
 		(isl38xx_control_block *) priv->control_block;
 	u32 curr_frag;
@@ -414,7 +414,7 @@
 void
 islpci_mgt_cleanup_transmit(struct net_device *ndev)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 	isl38xx_control_block *cb =    /* volatile not needed */
 		(isl38xx_control_block *) priv->control_block;
 	u32 curr_frag;
@@ -451,7 +451,7 @@
 		       void *senddata, int sendlen,
 		       struct islpci_mgmtframe **recvframe)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 	const long wait_cycle_jiffies = (ISL38XX_WAIT_CYCLE * 10 * HZ) / 1000;
 	long timeout_left = ISL38XX_MAX_WAIT_CYCLES * wait_cycle_jiffies;
 	int err;

--------------050609010905000107010904
Content-Type: text/plain;
 name="patch-b"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-b"

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1740  -> 1.1741 
#	drivers/net/wireless/prism54/islpci_eth.c	1.3     -> 1.4    
#	drivers/net/wireless/prism54/islpci_mgt.h	1.2     -> 1.3    
#	drivers/net/wireless/Kconfig	1.20    -> 1.21   
#	drivers/net/wireless/prism54/isl_ioctl.c	1.4     -> 1.5    
#	drivers/net/wireless/prism54/islpci_hotplug.c	1.3     -> 1.4    
#	drivers/net/wireless/prism54/isl_oid.h	1.1     -> 1.2    
#	drivers/net/wireless/prism54/islpci_mgt.c	1.4     -> 1.5    
#	drivers/net/wireless/prism54/oid_mgt.c	1.1     -> 1.2    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/03/17	mcgrof@studorgs.rutgers.edu	1.1741
# [wireless prism54] several minor updates
# 
# Here is the ChangeLog:
# 
# 	* wireless/Kconfig: fix typos, add SMC2835W-V2
# 	* islpci_hotplug.c: new version 1.1, authors list, and
# 	module description updated appropriately
# 	* isl_ioctl.c, islpci_dev.c, 
# 	islpci_eth.c, islpci_hotplug.c, islpci_mgt.c: 
# 	s/ndev->priv/netdev_priv(ndev)/g
# 	* islpci_hotplug.c: Add PCI ID values for SMC2835W-V2 cardbus card
# 	Patch by Manuel Lauss <manuel.lauss@fh-hagenberg.at>
# 	* isl_38xx.[ch]: include firmware.h in header, remove
# 	declaration of headers in c file. Fix compiler warnings.
# 	* islpci_dev.c (islpci_alloc_memory),
# 	* islpci_eth.c (islpci_eth_cleanup_transmit, 
# 	islpci_eth_transmit, islpci_eth_receive): deal with skb stray 
# 	pointer, declare NULL.
# 	* isl_38xx.c: remove unecessary __KERNEL_SYSCALLS__ and
# 	re-ordered headers per vger.kernel.org - liking.
# 	* isl_ioctl.c, islpci_mgt.c: move from MODULE_PARAM to the new
# 	module_param, which is type-safe. Includes the new 
# 	<linux/moduleparam.h>.
# 	* isl_ioctl.c (prism54_[s|g]et_[maxframeburst|profile]): added.
# 	Not adding ioctls as ajfa is working on moving current private ioctls
# 	to subioctls.
# 	* isl_oid.h (dot11_[maxframeburst|preamblesettings|
# 	slotsettings|nonerpstatus|nonerpprotection]_t): added.
# 	Note: more ioctls can be added here, I believe problems
# 	with mixed modes can be pinpointed here, with these values.
# --------------------------------------------
#
diff -Nru a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
--- a/drivers/net/wireless/Kconfig	Wed Mar 17 04:47:33 2004
+++ b/drivers/net/wireless/Kconfig	Wed Mar 17 04:47:33 2004
@@ -307,18 +307,18 @@
 	 It has basic support for Linux wireless extensions and initial
 	 micro support for ethtool.
 
-comment "Prism GT/Duette 802.11(a/b/g) PCI/PCMCIA support"
+comment "Prism GT/Duette 802.11(a/b/g) PCI/Cardbus support"
 	depends on NET_RADIO && PCI
 config PRISM54
-	tristate 'Intersil Prism GT/Duette/Indigo PCI/PCMCIA' 
+	tristate 'Intersil Prism GT/Duette/Indigo PCI/Cardbus' 
 	depends on PCI && NET_RADIO && EXPERIMENTAL && HOTPLUG
 	select FW_LOADER
 	---help---
 	  Enable PCI and Cardbus support for the following chipset based cards:
 
-	  ISL3880 - Prism GT		802.11 b/g
-	  ISL3877 - Prism Indigo	802.11 a
-	  ISL3890 - Prism Duette	802.11 a/b/g
+	  ISL3880 - Prism GT            802.11 b/g
+	  ISL3877 - Prism Indigo        802.11 a
+	  ISL3890 - Prism Duette        802.11 a/b/g
 	  
 	  For a complete list of supported cards visit <http://prism54.org>.
 	  Here is the latest confirmed list of supported cards:
@@ -335,8 +335,9 @@
 	  Peabird WLG-PCI PCI Card
 	  Sitecom WL-100i Cardbus Card
 	  Sitecom WL-110i PCI Card
-	  SMC2802W - EZ Connect g 2.4GHz 54 Mbps Wireless PCI Card
-	  SMC2835W - EZ Connect g 2.4GHz 54 Mbps Wireless Cardbus Card
+	  SMC2802W -    EZ Connect g 2.4GHz 54 Mbps Wireless PCI Card
+	  SMC2835W -    EZ Connect g 2.4GHz 54 Mbps Wireless Cardbus Card
+	  SMC2835W-V2 - EZ Connect g 2.4GHz 54 Mbps Wireless Cardbus Card
 	  Z-Com XG-900 PCI Card
 	  Zyxel G-100 Cardbus Card
 
diff -Nru a/drivers/net/wireless/prism54/isl_ioctl.c b/drivers/net/wireless/prism54/isl_ioctl.c
--- a/drivers/net/wireless/prism54/isl_ioctl.c	Wed Mar 17 04:47:33 2004
+++ b/drivers/net/wireless/prism54/isl_ioctl.c	Wed Mar 17 04:47:33 2004
@@ -25,6 +25,7 @@
 #include <linux/kernel.h>
 #include <linux/if_arp.h>
 #include <linux/pci.h>
+#include <linux/moduleparam.h>
 
 #include <asm/uaccess.h>
 
@@ -44,26 +45,26 @@
 static int init_conformance = CARD_DEFAULT_CONFORMANCE;
 static int init_mlme = CARD_DEFAULT_MLME_MODE;
 
-MODULE_PARM(init_mode, "i");
+module_param(init_mode, int, 0);
 MODULE_PARM_DESC(init_mode,
 		 "Set card mode:\n0: Auto\n1: Ad-Hoc\n2: Managed Client (Default)\n3: Master / Access Point\n4: Repeater (Not supported yet)\n5: Secondary (Not supported yet)\n6: Monitor");
 
-MODULE_PARM(init_channel, "i");
+module_param(init_channel, int, 0);
 MODULE_PARM_DESC(init_channel,
 		 "Check `iwpriv ethx channel` for available channels");
 
-MODULE_PARM(init_wep, "i");
-MODULE_PARM(init_filter, "i");
+module_param(init_wep, int, 0);
+module_param(init_filter, int, 0);
 
-MODULE_PARM(init_authen, "i");
+module_param(init_authen, int, 0);
 MODULE_PARM_DESC(init_authen,
 		 "Authentication method. Can be of seven types:\n0 0x0000: None\n1 0x0001: DOT11_AUTH_OS (Default)\n2 0x0002: DOT11_AUTH_SK\n3 0x0003: DOT11_AUTH_BOTH");
 
-MODULE_PARM(init_dot1x, "i");
+module_param(init_dot1x, int, 0);
 MODULE_PARM_DESC(init_dot1x,
 		 "\n0: None/not set	(Default)\n1: DOT11_DOT1X_AUTHENABLED\n2: DOT11_DOT1X_KEYTXENABLED");
 
-MODULE_PARM(init_mlme, "i");
+module_param(init_mlme, int, 0);
 MODULE_PARM_DESC(init_mlme,
 		 "Sets the MAC layer management entity (MLME) mode of operation,\n0: DOT11_MLME_AUTO (Default)\n1: DOT11_MLME_INTERMEDIATE\n2: DOT11_MLME_EXTENDED");
 
@@ -1944,16 +1945,70 @@
 prism54_get_wpa(struct net_device *ndev, struct iw_request_info *info,
 		__u32 * uwrq, char *extra)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 	*uwrq = priv->wpa;
 	return 0;
 }
 
 int
+prism54_set_maxframeburst(struct net_device *ndev, struct iw_request_info *info,
+		__u32 *uwrq, char *extra)
+{
+	islpci_private *priv = netdev_priv(ndev);
+	u32 max_burst;
+
+	max_burst = (*uwrq) ? *uwrq : CARD_DEFAULT_MAXFRAMEBURST;
+	mgt_set_request(priv, DOT11_OID_MAXFRAMEBURST, 0, &max_burst);
+
+	return -EINPROGRESS; /* Call commit handler */
+}
+
+int
+prism54_get_maxframeburst(struct net_device *ndev, struct iw_request_info *info,
+		__u32 *uwrq, char *extra)
+{
+	islpci_private *priv = netdev_priv(ndev);
+	union oid_res_t r;
+	int rvalue;
+	
+	rvalue = mgt_get_request(priv, DOT11_OID_MAXFRAMEBURST, 0, NULL, &r);
+	*uwrq = r.u;
+	
+	return rvalue;
+}
+
+int
+prism54_set_profile(struct net_device *ndev, struct iw_request_info *info,
+		__u32 *uwrq, char *extra)
+{
+	islpci_private *priv = netdev_priv(ndev);
+	u32 profile;
+
+	profile = (*uwrq) ? *uwrq : CARD_DEFAULT_PROFILE;
+	mgt_set_request(priv, DOT11_OID_PROFILES, 0, &profile);
+	
+	return -EINPROGRESS; /* Call commit handler */
+}
+
+int
+prism54_get_profile(struct net_device *ndev, struct iw_request_info *info,
+		__u32 *uwrq, char *extra)
+{
+	islpci_private *priv = netdev_priv(ndev);
+	union oid_res_t r;
+	int rvalue;
+
+	rvalue = mgt_get_request(priv, DOT11_OID_PROFILES, 0, NULL, &r);
+	*uwrq = r.u;
+
+	return rvalue;
+}
+
+int
 prism54_oid(struct net_device *ndev, struct iw_request_info *info,
 		__u32 *uwrq, char *extra)
 {
-	islpci_private *priv = ndev->priv;
+	islpci_private *priv = netdev_priv(ndev);
 	
 	priv->priv_oid = *uwrq;
 	printk("%s: oid 0x%08X\n", ndev->name, *uwrq);
diff -Nru a/drivers/net/wireless/prism54/isl_oid.h b/drivers/net/wireless/prism54/isl_oid.h
--- a/drivers/net/wireless/prism54/isl_oid.h	Wed Mar 17 04:47:33 2004
+++ b/drivers/net/wireless/prism54/isl_oid.h	Wed Mar 17 04:47:33 2004
@@ -1,7 +1,8 @@
 /*
- *  $Id: isl_oid.h,v 1.2 2004/01/30 16:24:00 ajfa Exp $
+ *  $Id: isl_oid.h,v 1.3 2004/03/09 09:05:27 mcgrof Exp $
  *  
  *  Copyright (C) 2003 Herbert Valerio Riedel <hvr@gnu.org>
+ *  Copyright (C) 2004 Luis R. Rodriguez <mcgrof@ruslug.rutgers.edu>
  *
  *  This program is free software; you can redistribute it and/or modify
  *  it under the terms of the GNU General Public License as published by
@@ -142,15 +143,131 @@
 	DOT11_PRIV_TKIP = 1
 };
 
+/* Prism "Nitro" / Frameburst / "Packet Frame Grouping"
+ * Value is in microseconds. Represents the # microseconds
+ * the firmware will take to group frames before sending out then out 
+ * together with a CSMA contention. Without this all frames are
+ * sent with a CSMA contention. 
+ * Bibliography: 
+ * http://www.hpl.hp.com/personal/Jean_Tourrilhes/Papers/Packet.Frame.Grouping.html
+ */
+enum dot11_maxframeburst_t { 
+	/* Values for DOT11_OID_MAXFRAMEBURST */
+	DOT11_MAXFRAMEBURST_OFF = 0, /* Card firmware default */
+	DOT11_MAXFRAMEBURST_MIXED_SAFE = 650, /* 802.11 a,b,g safe */
+	DOT11_MAXFRAMEBURST_IDEAL = 1300, /* Theoretical ideal level */
+	DOT11_MAXFRAMEBURST_MAX = 5000, /* Use this as max,
+		* Note: firmware allows for greater values. This is a
+		* recommended max. I'll update this as I find
+		* out what the real MAX is. Also note that you don't necessarily
+		* get better results with a greater value here.
+		*/
+};
+
+/* Support for 802.11 long and short frame preambles.
+ * Long	 preamble uses 128-bit sync field, 8-bit  CRC
+ * Short preamble uses 56-bit  sync field, 16-bit CRC
+ * 
+ * 802.11a -- not sure, both optionally ?
+ * 802.11b supports long and optionally short 
+ * 802.11g supports both */
+enum dot11_preamblesettings_t {
+	DOT11_PREAMBLESETTING_LONG = 0,
+		/* Allows *only* long 802.11 preambles */
+	DOT11_PREAMBLESETTING_SHORT = 1,
+		/* Allows *only* short 802.11 preambles */
+	DOT11_PREAMBLESETTING_DYNAMIC = 2
+		/* AutomatiGically set */
+};
+
+/* Support for 802.11 slot timing (time between packets).
+ *
+ * Long uses 802.11a slot timing  (9 usec ?)
+ * Short uses 802.11b slot timing (20 use ?) */
+enum dot11_slotsettings_t {
+	DOT11_SLOTSETTINGS_LONG = 0, 
+		/* Allows *only* long 802.11b slot timing */
+	DOT11_SLOTSETTINGS_SHORT = 1,
+		/* Allows *only* long 802.11a slot timing */
+	DOT11_SLOTSETTINGS_DYNAMIC = 2
+		/* AutomatiGically set */
+};
+
+/* All you need to know, ERP is "Extended Rate PHY".
+ * An Extended Rate PHY (ERP) STA or AP shall support three different 
+ * preamble and header formats:
+ * Long  preamble (refer to above)
+ * Short preamble (refer to above)
+ * OFDM  preamble ( ? )
+ *
+ * I'm assuming here Protection tells the AP
+ * to be careful, a STA which cannot handle the long pre-amble
+ * has joined.
+ */
+enum do11_nonerpstatus_t {
+	DOT11_ERPSTAT_NONEPRESENT = 0,
+	DOT11_ERPSTAT_USEPROTECTION = 1
+};
+
+/* (ERP is "Extended Rate PHY") Way to read NONERP is NON-ERP-*
+ * The key here is DOT11 NON ERP NEVER protects against
+ * NON ERP STA's. You *don't* want this unless
+ * you know what you are doing. It means you will only 
+ * get Extended Rate capabilities */
+enum dot11_nonerpprotection_t {
+	DOT11_NONERP_NEVER = 0,
+	DOT11_NONERP_ALWAYS = 1,
+	DOT11_NONERP_DYNAMIC = 2
+};
+
+/* Preset OID configuration for 802.11 modes 
+ * Note: DOT11_OID_CW[MIN|MAX] hold the values of the 
+ * DCS MIN|MAX backoff used */
+enum dot11_profile_t { /* And set/allowed values */
+	/* Allowed values for DOT11_OID_PROFILES */
+	DOT11_PROFILE_B_ONLY = 0,
+		/* DOT11_OID_RATES: 1, 2, 5.5, 11Mbps 
+		 * DOT11_OID_PREAMBLESETTINGS: DOT11_PREAMBLESETTING_DYNAMIC
+		 * DOT11_OID_CWMIN: 31
+		 * DOT11_OID_NONEPROTECTION: DOT11_NOERP_DYNAMIC
+		 * DOT11_OID_SLOTSETTINGS: DOT11_SLOTSETTINGS_LONG
+		 */
+	DOT11_PROFILE_MIXED_G_WIFI = 1,
+		/* DOT11_OID_RATES: 1, 2, 5.5, 11, 6, 9, 12, 18, 24, 36, 48, 54Mbs
+		 * DOT11_OID_PREAMBLESETTINGS: DOT11_PREAMBLESETTING_DYNAMIC
+		 * DOT11_OID_CWMIN: 15
+		 * DOT11_OID_NONEPROTECTION: DOT11_NOERP_DYNAMIC
+		 * DOT11_OID_SLOTSETTINGS: DOT11_SLOTSETTINGS_DYNAMIC
+		 */
+	DOT11_PROFILE_MIXED_LONG = 2, /* "Long range" */
+		/* Same as Profile MIXED_G_WIFI */
+	DOT11_PROFILE_G_ONLY = 3,
+		/* Same as Profile MIXED_G_WIFI */
+	DOT11_PROFILE_TEST = 4,
+		/* Same as Profile MIXED_G_WIFI except:
+		 * DOT11_OID_PREAMBLESETTINGS: DOT11_PREAMBLESETTING_SHORT
+		 * DOT11_OID_NONEPROTECTION: DOT11_NOERP_NEVER
+		 * DOT11_OID_SLOTSETTINGS: DOT11_SLOTSETTINGS_SHORT
+		 */
+	DOT11_PROFILE_B_WIFI = 5,
+		/* Same as Profile B_ONLY */
+	DOT11_PROFILE_A_ONLY = 6,
+		/* Same as Profile MIXED_G_WIFI except:
+		 * DOT11_OID_RATES: 6, 9, 12, 18, 24, 36, 48, 54Mbs
+		 */
+	DOT11_PROFILE_MIXED_SHORT = 7
+		/* Same as MIXED_G_WIFI */
+};
+
+
 /* The dot11d conformance level configures the 802.11d conformance levels.
  * The following conformance levels exist:*/
 enum oid_inl_conformance_t {
 	OID_INL_CONFORMANCE_NONE = 0,	/* Perform active scanning */
 	OID_INL_CONFORMANCE_STRICT = 1,	/* Strictly adhere to 802.11d */
 	OID_INL_CONFORMANCE_FLEXIBLE = 2,	/* Use passed 802.11d info to
-						 * determine channel AND/OR just make 
-						 * assumption that active 
-						 * channels are valid  channels */
+		* determine channel AND/OR just make assumption that active 
+		* channels are valid  channels */
 };
 
 enum oid_inl_mode_t {
@@ -176,6 +293,7 @@
 	INL_PHYCAP_FAA = 0x80000000,	/* Means card supports the FAA switch */
 };
 
+
 enum oid_num_t {
 	GEN_OID_MACADDRESS = 0,
 	GEN_OID_LINKSTATE,
@@ -269,8 +387,8 @@
 	DOT11_OID_FRAMEABORTSPHY,
 
 	DOT11_OID_SLOTTIME,
-	DOT11_OID_CWMIN,
-	DOT11_OID_CWMAX,
+	DOT11_OID_CWMIN, /* MIN DCS backoff */
+	DOT11_OID_CWMAX, /* MAX DCS backoff */
 	DOT11_OID_ACKWINDOW,
 	DOT11_OID_ANTENNARX,
 	DOT11_OID_ANTENNATX,
diff -Nru a/drivers/net/wireless/prism54/islpci_eth.c b/drivers/net/wireless/prism54/islpci_eth.c
--- a/drivers/net/wireless/prism54/islpci_eth.c	Wed Mar 17 04:47:33 2004
+++ b/drivers/net/wireless/prism54/islpci_eth.c	Wed Mar 17 04:47:33 2004
@@ -63,6 +63,7 @@
 					 priv->pci_map_tx_address[index],
 					 skb->len, PCI_DMA_TODEVICE);
 			dev_kfree_skb_irq(skb);
+			skb = NULL;
 		}
 		/* increment the free data low queue pointer */
 		priv->free_data_tx++;
@@ -238,6 +239,7 @@
  drop_free:
 	/* free the skbuf structure before aborting */
 	dev_kfree_skb(skb);
+	skb = NULL;
 
 	priv->statistics.tx_dropped++;
 	spin_unlock_irqrestore(&priv->slock, flags);
@@ -346,8 +348,10 @@
 	     skb->data[0], skb->data[1], skb->data[2], skb->data[3],
 	     skb->data[4], skb->data[5]);
 #endif
-	if (discard)
+	if (discard) {
 		dev_kfree_skb(skb);
+		skb = NULL;
+	}
 	else
 		netif_rx(skb);
 
@@ -388,6 +392,7 @@
 
 			/* free the skbuf structure before aborting */
 			dev_kfree_skb((struct sk_buff *) skb);
+			skb = NULL;
 			break;
 		}
 		/* update the fragment address */
diff -Nru a/drivers/net/wireless/prism54/islpci_hotplug.c b/drivers/net/wireless/prism54/islpci_hotplug.c
--- a/drivers/net/wireless/prism54/islpci_hotplug.c	Wed Mar 17 04:47:33 2004
+++ b/drivers/net/wireless/prism54/islpci_hotplug.c	Wed Mar 17 04:47:33 2004
@@ -29,10 +29,10 @@
 #include "isl_oid.h"
 
 #define DRV_NAME	"prism54"
-#define DRV_VERSION	"1.0.2.2"
+#define DRV_VERSION	"1.1"
 
-MODULE_AUTHOR("W.Termorshuizen, R.Bastings, H.V.Riedel, prism54.org team");
-MODULE_DESCRIPTION("Intersil 802.11 Wireless LAN adapter");
+MODULE_AUTHOR("[Intersil] R.Bastings and W.Termorshuizen, The prism54.org Development Team <prism54-devel@prism54.org>");
+MODULE_DESCRIPTION("The Prism54 802.11 Wireless LAN adapter");
 MODULE_LICENSE("GPL");
 
 /* In this order: vendor, device, subvendor, subdevice, class, class_mask,
@@ -97,6 +97,11 @@
 	 0, 0,
 	 (unsigned long) "SMC 2802Wv2"},
 	{
+	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
+	 PCIVENDOR_SMC, 0xa835UL,
+	 0, 0,
+	 (unsigned long) "SMC 2835Wv2"},
+	{
 	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3877,
 	 PCI_ANY_ID, PCI_ANY_ID,
 	 0, 0,
@@ -158,6 +163,9 @@
 		break;
 	case 0x2835UL:
 		modelp = "SMC2835W";
+		break;
+	case 0xa835UL:
+		modelp = "SMC2835W V2";
 		break;
 	/* Let's leave this one out for now since it seems bogus/wrong 
 	 * Even if the manufacturer did use 0x0000UL it may not be correct
diff -Nru a/drivers/net/wireless/prism54/islpci_mgt.c b/drivers/net/wireless/prism54/islpci_mgt.c
--- a/drivers/net/wireless/prism54/islpci_mgt.c	Wed Mar 17 04:47:33 2004
+++ b/drivers/net/wireless/prism54/islpci_mgt.c	Wed Mar 17 04:47:33 2004
@@ -22,6 +22,7 @@
 #include <linux/netdevice.h>
 #include <linux/module.h>
 #include <linux/pci.h>
+#include <linux/moduleparam.h>
 
 #include <asm/io.h>
 #include <asm/system.h>
@@ -38,7 +39,7 @@
         Global variable definition section
 ******************************************************************************/
 int pc_debug = VERBOSE;
-MODULE_PARM(pc_debug, "i");
+module_param(pc_debug, int, 0);
 
 /******************************************************************************
     Driver general functions
diff -Nru a/drivers/net/wireless/prism54/islpci_mgt.h b/drivers/net/wireless/prism54/islpci_mgt.h
--- a/drivers/net/wireless/prism54/islpci_mgt.h	Wed Mar 17 04:47:33 2004
+++ b/drivers/net/wireless/prism54/islpci_mgt.h	Wed Mar 17 04:47:33 2004
@@ -87,11 +87,13 @@
 #define CARD_DEFAULT_KEY4                       "default_key_4"
 #define CARD_DEFAULT_WEP                        0
 #define CARD_DEFAULT_FILTER                     0
-# define CARD_DEFAULT_WDS                        0
+#define CARD_DEFAULT_WDS                        0
 #define	CARD_DEFAULT_AUTHEN                     DOT11_AUTH_OS
 #define	CARD_DEFAULT_DOT1X			0
 #define CARD_DEFAULT_MLME_MODE			DOT11_MLME_AUTO
 #define CARD_DEFAULT_CONFORMANCE                OID_INL_CONFORMANCE_NONE
+#define CARD_DEFAULT_PROFILE			DOT11_PROFILE_MIXED_G_WIFI
+#define CARD_DEFAULT_MAXFRAMEBURST		DOT11_MAXFRAMEBURST_MIXED_SAFE
 
 /* PIMFOR package definitions */
 #define PIMFOR_ETHERTYPE                        0x8828
diff -Nru a/drivers/net/wireless/prism54/oid_mgt.c b/drivers/net/wireless/prism54/oid_mgt.c
--- a/drivers/net/wireless/prism54/oid_mgt.c	Wed Mar 17 04:47:33 2004
+++ b/drivers/net/wireless/prism54/oid_mgt.c	Wed Mar 17 04:47:33 2004
@@ -97,7 +97,7 @@
 	[DOT11_OID_ALOFT_CONFIG] = OID_UNKNOWN(0x1d000006),
 
 	[DOT11_OID_VDCFX] = {0x1b000000, 7, 0, 0},
-	[DOT11_OID_MAXFRAMEBURST] = OID_U32(0x1b000008),
+	[DOT11_OID_MAXFRAMEBURST] = OID_U32(0x1b000008), /* in microseconds */
 
 	[DOT11_OID_PSM] = OID_U32(0x14000000),
 	[DOT11_OID_CAMTIMEOUT] = OID_U32(0x14000001),

--------------050609010905000107010904--
