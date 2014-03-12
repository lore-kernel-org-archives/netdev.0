From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 2/6] bluetooth: Convert uses of __constant_<foo> to <foo>
Date: Wed, 12 Mar 2014 10:04:16 -0700
Message-ID: <51892631f2289665bf47b294c783ee9560a8317e.1394643455.git.joe@perches.com>
References: <cover.1394643455.git.joe@perches.com>
Cc: Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1394643455.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The use of __constant_<foo> has been unnecessary for quite awhile now.

Make these uses consistent with the rest of the kernel.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/bluetooth/a2mp.c        |  4 +-
 net/bluetooth/hci_conn.c    | 26 ++++++-------
 net/bluetooth/hci_core.c    |  2 +-
 net/bluetooth/hci_event.c   |  6 +--
 net/bluetooth/hci_sock.c    | 16 ++++----
 net/bluetooth/l2cap_core.c  | 90 ++++++++++++++++++++++-----------------------
 net/bluetooth/l2cap_sock.c  |  6 +--
 net/bluetooth/mgmt.c        | 26 ++++++-------
 net/bluetooth/rfcomm/core.c |  4 +-
 net/bluetooth/sco.c         | 10 ++---
 net/bluetooth/smp.c         |  2 +-
 11 files changed, 96 insertions(+), 96 deletions(-)

diff --git a/net/bluetooth/a2mp.c b/net/bluetooth/a2mp.c
index efcd108..8df4a8b 100644
--- a/net/bluetooth/a2mp.c
+++ b/net/bluetooth/a2mp.c
@@ -162,7 +162,7 @@ static int a2mp_discover_req(struct amp_mgr *mgr, struct sk_buff *skb,
 		return -ENOMEM;
 	}
 
-	rsp->mtu = __constant_cpu_to_le16(L2CAP_A2MP_DEFAULT_MTU);
+	rsp->mtu = cpu_to_le16(L2CAP_A2MP_DEFAULT_MTU);
 	rsp->ext_feat = 0;
 
 	__a2mp_add_cl(mgr, rsp->cl);
@@ -649,7 +649,7 @@ static int a2mp_chan_recv_cb(struct l2cap_chan *chan, struct sk_buff *skb)
 	if (err) {
 		struct a2mp_cmd_rej rej;
 
-		rej.reason = __constant_cpu_to_le16(0);
+		rej.reason = cpu_to_le16(0);
 		hdr = (void *) skb->data;
 
 		BT_DBG("Send A2MP Rej: cmd 0x%2.2x err %d", hdr->code, err);
diff --git a/net/bluetooth/hci_conn.c b/net/bluetooth/hci_conn.c
index ba5366c..b833bf2 100644
--- a/net/bluetooth/hci_conn.c
+++ b/net/bluetooth/hci_conn.c
@@ -82,7 +82,7 @@ static void hci_acl_create_connection(struct hci_conn *conn)
 			cp.pscan_rep_mode = ie->data.pscan_rep_mode;
 			cp.pscan_mode     = ie->data.pscan_mode;
 			cp.clock_offset   = ie->data.clock_offset |
-					    __constant_cpu_to_le16(0x8000);
+					    cpu_to_le16(0x8000);
 		}
 
 		memcpy(conn->dev_class, ie->data.dev_class, 3);
@@ -182,8 +182,8 @@ bool hci_setup_sync(struct hci_conn *conn, __u16 handle)
 
 	cp.handle   = cpu_to_le16(handle);
 
-	cp.tx_bandwidth   = __constant_cpu_to_le32(0x00001f40);
-	cp.rx_bandwidth   = __constant_cpu_to_le32(0x00001f40);
+	cp.tx_bandwidth   = cpu_to_le32(0x00001f40);
+	cp.rx_bandwidth   = cpu_to_le32(0x00001f40);
 	cp.voice_setting  = cpu_to_le16(conn->setting);
 
 	switch (conn->setting & SCO_AIRMODE_MASK) {
@@ -225,8 +225,8 @@ void hci_le_conn_update(struct hci_conn *conn, u16 min, u16 max,
 	cp.conn_interval_max	= cpu_to_le16(max);
 	cp.conn_latency		= cpu_to_le16(latency);
 	cp.supervision_timeout	= cpu_to_le16(to_multiplier);
-	cp.min_ce_len		= __constant_cpu_to_le16(0x0001);
-	cp.max_ce_len		= __constant_cpu_to_le16(0x0001);
+	cp.min_ce_len		= cpu_to_le16(0x0001);
+	cp.max_ce_len		= cpu_to_le16(0x0001);
 
 	hci_send_cmd(hdev, HCI_OP_LE_CONN_UPDATE, sizeof(cp), &cp);
 }
@@ -337,9 +337,9 @@ static void hci_conn_idle(struct work_struct *work)
 	if (lmp_sniffsubr_capable(hdev) && lmp_sniffsubr_capable(conn)) {
 		struct hci_cp_sniff_subrate cp;
 		cp.handle             = cpu_to_le16(conn->handle);
-		cp.max_latency        = __constant_cpu_to_le16(0);
-		cp.min_remote_timeout = __constant_cpu_to_le16(0);
-		cp.min_local_timeout  = __constant_cpu_to_le16(0);
+		cp.max_latency        = cpu_to_le16(0);
+		cp.min_remote_timeout = cpu_to_le16(0);
+		cp.min_local_timeout  = cpu_to_le16(0);
 		hci_send_cmd(hdev, HCI_OP_SNIFF_SUBRATE, sizeof(cp), &cp);
 	}
 
@@ -348,8 +348,8 @@ static void hci_conn_idle(struct work_struct *work)
 		cp.handle       = cpu_to_le16(conn->handle);
 		cp.max_interval = cpu_to_le16(hdev->sniff_max_interval);
 		cp.min_interval = cpu_to_le16(hdev->sniff_min_interval);
-		cp.attempt      = __constant_cpu_to_le16(4);
-		cp.timeout      = __constant_cpu_to_le16(1);
+		cp.attempt      = cpu_to_le16(4);
+		cp.timeout      = cpu_to_le16(1);
 		hci_send_cmd(hdev, HCI_OP_SNIFF_MODE, sizeof(cp), &cp);
 	}
 }
@@ -560,9 +560,9 @@ static int hci_create_le_conn(struct hci_conn *conn)
 	cp.own_address_type = conn->src_type;
 	cp.conn_interval_min = cpu_to_le16(hdev->le_conn_min_interval);
 	cp.conn_interval_max = cpu_to_le16(hdev->le_conn_max_interval);
-	cp.supervision_timeout = __constant_cpu_to_le16(0x002a);
-	cp.min_ce_len = __constant_cpu_to_le16(0x0000);
-	cp.max_ce_len = __constant_cpu_to_le16(0x0000);
+	cp.supervision_timeout = cpu_to_le16(0x002a);
+	cp.min_ce_len = cpu_to_le16(0x0000);
+	cp.max_ce_len = cpu_to_le16(0x0000);
 
 	hci_req_add(&req, HCI_OP_LE_CREATE_CONN, sizeof(cp), &cp);
 
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index 5e8663c..9b89aa5 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -1005,7 +1005,7 @@ static void bredr_setup(struct hci_request *req)
 	hci_req_add(req, HCI_OP_SET_EVENT_FLT, 1, &flt_type);
 
 	/* Connection accept timeout ~20 secs */
-	param = __constant_cpu_to_le16(0x7d00);
+	param = cpu_to_le16(0x7d00);
 	hci_req_add(req, HCI_OP_WRITE_CA_TIMEOUT, 2, &param);
 
 	/* AVM Berlin (31), aka "BlueFRITZ!", reports version 1.2,
diff --git a/net/bluetooth/hci_event.c b/net/bluetooth/hci_event.c
index 5f81245..c1e5bac 100644
--- a/net/bluetooth/hci_event.c
+++ b/net/bluetooth/hci_event.c
@@ -1738,9 +1738,9 @@ static void hci_conn_request_evt(struct hci_dev *hdev, struct sk_buff *skb)
 			bacpy(&cp.bdaddr, &ev->bdaddr);
 			cp.pkt_type = cpu_to_le16(conn->pkt_type);
 
-			cp.tx_bandwidth   = __constant_cpu_to_le32(0x00001f40);
-			cp.rx_bandwidth   = __constant_cpu_to_le32(0x00001f40);
-			cp.max_latency    = __constant_cpu_to_le16(0xffff);
+			cp.tx_bandwidth   = cpu_to_le32(0x00001f40);
+			cp.rx_bandwidth   = cpu_to_le32(0x00001f40);
+			cp.max_latency    = cpu_to_le16(0xffff);
 			cp.content_format = cpu_to_le16(hdev->voice_setting);
 			cp.retrans_effort = 0xff;
 
diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
index 7552f9e..9932400 100644
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -211,22 +211,22 @@ void hci_send_to_monitor(struct hci_dev *hdev, struct sk_buff *skb)
 
 	switch (bt_cb(skb)->pkt_type) {
 	case HCI_COMMAND_PKT:
-		opcode = __constant_cpu_to_le16(HCI_MON_COMMAND_PKT);
+		opcode = cpu_to_le16(HCI_MON_COMMAND_PKT);
 		break;
 	case HCI_EVENT_PKT:
-		opcode = __constant_cpu_to_le16(HCI_MON_EVENT_PKT);
+		opcode = cpu_to_le16(HCI_MON_EVENT_PKT);
 		break;
 	case HCI_ACLDATA_PKT:
 		if (bt_cb(skb)->incoming)
-			opcode = __constant_cpu_to_le16(HCI_MON_ACL_RX_PKT);
+			opcode = cpu_to_le16(HCI_MON_ACL_RX_PKT);
 		else
-			opcode = __constant_cpu_to_le16(HCI_MON_ACL_TX_PKT);
+			opcode = cpu_to_le16(HCI_MON_ACL_TX_PKT);
 		break;
 	case HCI_SCODATA_PKT:
 		if (bt_cb(skb)->incoming)
-			opcode = __constant_cpu_to_le16(HCI_MON_SCO_RX_PKT);
+			opcode = cpu_to_le16(HCI_MON_SCO_RX_PKT);
 		else
-			opcode = __constant_cpu_to_le16(HCI_MON_SCO_TX_PKT);
+			opcode = cpu_to_le16(HCI_MON_SCO_TX_PKT);
 		break;
 	default:
 		return;
@@ -319,7 +319,7 @@ static struct sk_buff *create_monitor_event(struct hci_dev *hdev, int event)
 		bacpy(&ni->bdaddr, &hdev->bdaddr);
 		memcpy(ni->name, hdev->name, 8);
 
-		opcode = __constant_cpu_to_le16(HCI_MON_NEW_INDEX);
+		opcode = cpu_to_le16(HCI_MON_NEW_INDEX);
 		break;
 
 	case HCI_DEV_UNREG:
@@ -327,7 +327,7 @@ static struct sk_buff *create_monitor_event(struct hci_dev *hdev, int event)
 		if (!skb)
 			return NULL;
 
-		opcode = __constant_cpu_to_le16(HCI_MON_DEL_INDEX);
+		opcode = cpu_to_le16(HCI_MON_DEL_INDEX);
 		break;
 
 	default:
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index b0ad2c7..08d219f 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -681,7 +681,7 @@ static void l2cap_chan_connect_reject(struct l2cap_chan *chan)
 	rsp.scid   = cpu_to_le16(chan->dcid);
 	rsp.dcid   = cpu_to_le16(chan->scid);
 	rsp.result = cpu_to_le16(result);
-	rsp.status = __constant_cpu_to_le16(L2CAP_CS_NO_INFO);
+	rsp.status = cpu_to_le16(L2CAP_CS_NO_INFO);
 
 	l2cap_send_cmd(conn, chan->ident, L2CAP_CONN_RSP, sizeof(rsp), &rsp);
 }
@@ -745,7 +745,7 @@ static inline u8 l2cap_get_auth_type(struct l2cap_chan *chan)
 		}
 		break;
 	case L2CAP_CHAN_CONN_LESS:
-		if (chan->psm == __constant_cpu_to_le16(L2CAP_PSM_3DSP)) {
+		if (chan->psm == cpu_to_le16(L2CAP_PSM_3DSP)) {
 			if (chan->sec_level == BT_SECURITY_LOW)
 				chan->sec_level = BT_SECURITY_SDP;
 		}
@@ -755,7 +755,7 @@ static inline u8 l2cap_get_auth_type(struct l2cap_chan *chan)
 			return HCI_AT_NO_BONDING;
 		break;
 	case L2CAP_CHAN_CONN_ORIENTED:
-		if (chan->psm == __constant_cpu_to_le16(L2CAP_PSM_SDP)) {
+		if (chan->psm == cpu_to_le16(L2CAP_PSM_SDP)) {
 			if (chan->sec_level == BT_SECURITY_LOW)
 				chan->sec_level = BT_SECURITY_SDP;
 
@@ -1288,7 +1288,7 @@ static void l2cap_do_start(struct l2cap_chan *chan)
 		}
 	} else {
 		struct l2cap_info_req req;
-		req.type = __constant_cpu_to_le16(L2CAP_IT_FEAT_MASK);
+		req.type = cpu_to_le16(L2CAP_IT_FEAT_MASK);
 
 		conn->info_state |= L2CAP_INFO_FEAT_MASK_REQ_SENT;
 		conn->info_ident = l2cap_get_ident(conn);
@@ -1385,18 +1385,18 @@ static void l2cap_conn_start(struct l2cap_conn *conn)
 
 			if (l2cap_chan_check_security(chan)) {
 				if (test_bit(FLAG_DEFER_SETUP, &chan->flags)) {
-					rsp.result = __constant_cpu_to_le16(L2CAP_CR_PEND);
-					rsp.status = __constant_cpu_to_le16(L2CAP_CS_AUTHOR_PEND);
+					rsp.result = cpu_to_le16(L2CAP_CR_PEND);
+					rsp.status = cpu_to_le16(L2CAP_CS_AUTHOR_PEND);
 					chan->ops->defer(chan);
 
 				} else {
 					l2cap_state_change(chan, BT_CONFIG);
-					rsp.result = __constant_cpu_to_le16(L2CAP_CR_SUCCESS);
-					rsp.status = __constant_cpu_to_le16(L2CAP_CS_NO_INFO);
+					rsp.result = cpu_to_le16(L2CAP_CR_SUCCESS);
+					rsp.status = cpu_to_le16(L2CAP_CS_NO_INFO);
 				}
 			} else {
-				rsp.result = __constant_cpu_to_le16(L2CAP_CR_PEND);
-				rsp.status = __constant_cpu_to_le16(L2CAP_CS_AUTHEN_PEND);
+				rsp.result = cpu_to_le16(L2CAP_CR_PEND);
+				rsp.status = cpu_to_le16(L2CAP_CS_AUTHEN_PEND);
 			}
 
 			l2cap_send_cmd(conn, chan->ident, L2CAP_CONN_RSP,
@@ -3099,9 +3099,9 @@ static struct sk_buff *l2cap_build_cmd(struct l2cap_conn *conn, u8 code,
 	lh->len = cpu_to_le16(L2CAP_CMD_HDR_SIZE + dlen);
 
 	if (conn->hcon->type == LE_LINK)
-		lh->cid = __constant_cpu_to_le16(L2CAP_CID_LE_SIGNALING);
+		lh->cid = cpu_to_le16(L2CAP_CID_LE_SIGNALING);
 	else
-		lh->cid = __constant_cpu_to_le16(L2CAP_CID_SIGNALING);
+		lh->cid = cpu_to_le16(L2CAP_CID_SIGNALING);
 
 	cmd = (struct l2cap_cmd_hdr *) skb_put(skb, L2CAP_CMD_HDR_SIZE);
 	cmd->code  = code;
@@ -3214,8 +3214,8 @@ static void l2cap_add_opt_efs(void **ptr, struct l2cap_chan *chan)
 		efs.stype	= chan->local_stype;
 		efs.msdu	= cpu_to_le16(chan->local_msdu);
 		efs.sdu_itime	= cpu_to_le32(chan->local_sdu_itime);
-		efs.acc_lat	= __constant_cpu_to_le32(L2CAP_DEFAULT_ACC_LAT);
-		efs.flush_to	= __constant_cpu_to_le32(L2CAP_EFS_DEFAULT_FLUSH_TO);
+		efs.acc_lat	= cpu_to_le32(L2CAP_DEFAULT_ACC_LAT);
+		efs.flush_to	= cpu_to_le32(L2CAP_EFS_DEFAULT_FLUSH_TO);
 		break;
 
 	case L2CAP_MODE_STREAMING:
@@ -3356,8 +3356,8 @@ static void __l2cap_set_ertm_timeouts(struct l2cap_chan *chan,
 		rfc->retrans_timeout = cpu_to_le16((u16) ertm_to);
 		rfc->monitor_timeout = rfc->retrans_timeout;
 	} else {
-		rfc->retrans_timeout = __constant_cpu_to_le16(L2CAP_DEFAULT_RETRANS_TO);
-		rfc->monitor_timeout = __constant_cpu_to_le16(L2CAP_DEFAULT_MONITOR_TO);
+		rfc->retrans_timeout = cpu_to_le16(L2CAP_DEFAULT_RETRANS_TO);
+		rfc->monitor_timeout = cpu_to_le16(L2CAP_DEFAULT_MONITOR_TO);
 	}
 }
 
@@ -3489,7 +3489,7 @@ done:
 	}
 
 	req->dcid  = cpu_to_le16(chan->dcid);
-	req->flags = __constant_cpu_to_le16(0);
+	req->flags = cpu_to_le16(0);
 
 	return ptr - data;
 }
@@ -3703,7 +3703,7 @@ done:
 	}
 	rsp->scid   = cpu_to_le16(chan->dcid);
 	rsp->result = cpu_to_le16(result);
-	rsp->flags  = __constant_cpu_to_le16(0);
+	rsp->flags  = cpu_to_le16(0);
 
 	return ptr - data;
 }
@@ -3812,7 +3812,7 @@ static int l2cap_parse_conf_rsp(struct l2cap_chan *chan, void *rsp, int len,
 	}
 
 	req->dcid   = cpu_to_le16(chan->dcid);
-	req->flags  = __constant_cpu_to_le16(0);
+	req->flags  = cpu_to_le16(0);
 
 	return ptr - data;
 }
@@ -3843,7 +3843,7 @@ void __l2cap_le_connect_rsp_defer(struct l2cap_chan *chan)
 	rsp.mtu     = cpu_to_le16(chan->imtu);
 	rsp.mps     = cpu_to_le16(chan->mps);
 	rsp.credits = cpu_to_le16(chan->rx_credits);
-	rsp.result  = __constant_cpu_to_le16(L2CAP_CR_SUCCESS);
+	rsp.result  = cpu_to_le16(L2CAP_CR_SUCCESS);
 
 	l2cap_send_cmd(conn, chan->ident, L2CAP_LE_CONN_RSP, sizeof(rsp),
 		       &rsp);
@@ -3858,8 +3858,8 @@ void __l2cap_connect_rsp_defer(struct l2cap_chan *chan)
 
 	rsp.scid   = cpu_to_le16(chan->dcid);
 	rsp.dcid   = cpu_to_le16(chan->scid);
-	rsp.result = __constant_cpu_to_le16(L2CAP_CR_SUCCESS);
-	rsp.status = __constant_cpu_to_le16(L2CAP_CS_NO_INFO);
+	rsp.result = cpu_to_le16(L2CAP_CR_SUCCESS);
+	rsp.status = cpu_to_le16(L2CAP_CS_NO_INFO);
 
 	if (chan->hs_hcon)
 		rsp_code = L2CAP_CREATE_CHAN_RSP;
@@ -3888,8 +3888,8 @@ static void l2cap_conf_rfc_get(struct l2cap_chan *chan, void *rsp, int len)
 	u16 txwin_ext = chan->ack_win;
 	struct l2cap_conf_rfc rfc = {
 		.mode = chan->mode,
-		.retrans_timeout = __constant_cpu_to_le16(L2CAP_DEFAULT_RETRANS_TO),
-		.monitor_timeout = __constant_cpu_to_le16(L2CAP_DEFAULT_MONITOR_TO),
+		.retrans_timeout = cpu_to_le16(L2CAP_DEFAULT_RETRANS_TO),
+		.monitor_timeout = cpu_to_le16(L2CAP_DEFAULT_MONITOR_TO),
 		.max_pdu_size = cpu_to_le16(chan->imtu),
 		.txwin_size = min_t(u16, chan->ack_win, L2CAP_DEFAULT_TX_WINDOW),
 	};
@@ -3980,7 +3980,7 @@ static struct l2cap_chan *l2cap_connect(struct l2cap_conn *conn,
 	l2cap_chan_lock(pchan);
 
 	/* Check if the ACL is secure enough (if not SDP) */
-	if (psm != __constant_cpu_to_le16(L2CAP_PSM_SDP) &&
+	if (psm != cpu_to_le16(L2CAP_PSM_SDP) &&
 	    !hci_conn_check_link_mode(conn->hcon)) {
 		conn->disc_reason = HCI_ERROR_AUTH_FAILURE;
 		result = L2CAP_CR_SEC_BLOCK;
@@ -4065,7 +4065,7 @@ sendresp:
 
 	if (result == L2CAP_CR_PEND && status == L2CAP_CS_NO_INFO) {
 		struct l2cap_info_req info;
-		info.type = __constant_cpu_to_le16(L2CAP_IT_FEAT_MASK);
+		info.type = cpu_to_le16(L2CAP_IT_FEAT_MASK);
 
 		conn->info_state |= L2CAP_INFO_FEAT_MASK_REQ_SENT;
 		conn->info_ident = l2cap_get_ident(conn);
@@ -4214,7 +4214,7 @@ static void cmd_reject_invalid_cid(struct l2cap_conn *conn, u8 ident,
 {
 	struct l2cap_cmd_rej_cid rej;
 
-	rej.reason = __constant_cpu_to_le16(L2CAP_REJ_INVALID_CID);
+	rej.reason = cpu_to_le16(L2CAP_REJ_INVALID_CID);
 	rej.scid = __cpu_to_le16(scid);
 	rej.dcid = __cpu_to_le16(dcid);
 
@@ -4546,8 +4546,8 @@ static inline int l2cap_information_req(struct l2cap_conn *conn,
 		u8 buf[8];
 		u32 feat_mask = l2cap_feat_mask;
 		struct l2cap_info_rsp *rsp = (struct l2cap_info_rsp *) buf;
-		rsp->type   = __constant_cpu_to_le16(L2CAP_IT_FEAT_MASK);
-		rsp->result = __constant_cpu_to_le16(L2CAP_IR_SUCCESS);
+		rsp->type   = cpu_to_le16(L2CAP_IT_FEAT_MASK);
+		rsp->result = cpu_to_le16(L2CAP_IR_SUCCESS);
 		if (!disable_ertm)
 			feat_mask |= L2CAP_FEAT_ERTM | L2CAP_FEAT_STREAMING
 				| L2CAP_FEAT_FCS;
@@ -4567,15 +4567,15 @@ static inline int l2cap_information_req(struct l2cap_conn *conn,
 		else
 			l2cap_fixed_chan[0] &= ~L2CAP_FC_A2MP;
 
-		rsp->type   = __constant_cpu_to_le16(L2CAP_IT_FIXED_CHAN);
-		rsp->result = __constant_cpu_to_le16(L2CAP_IR_SUCCESS);
+		rsp->type   = cpu_to_le16(L2CAP_IT_FIXED_CHAN);
+		rsp->result = cpu_to_le16(L2CAP_IR_SUCCESS);
 		memcpy(rsp->data, l2cap_fixed_chan, sizeof(l2cap_fixed_chan));
 		l2cap_send_cmd(conn, cmd->ident, L2CAP_INFO_RSP, sizeof(buf),
 			       buf);
 	} else {
 		struct l2cap_info_rsp rsp;
 		rsp.type   = cpu_to_le16(type);
-		rsp.result = __constant_cpu_to_le16(L2CAP_IR_NOTSUPP);
+		rsp.result = cpu_to_le16(L2CAP_IR_NOTSUPP);
 		l2cap_send_cmd(conn, cmd->ident, L2CAP_INFO_RSP, sizeof(rsp),
 			       &rsp);
 	}
@@ -4620,7 +4620,7 @@ static inline int l2cap_information_rsp(struct l2cap_conn *conn,
 
 		if (conn->feat_mask & L2CAP_FEAT_FIXED_CHAN) {
 			struct l2cap_info_req req;
-			req.type = __constant_cpu_to_le16(L2CAP_IT_FIXED_CHAN);
+			req.type = cpu_to_le16(L2CAP_IT_FIXED_CHAN);
 
 			conn->info_ident = l2cap_get_ident(conn);
 
@@ -4714,8 +4714,8 @@ static int l2cap_create_channel_req(struct l2cap_conn *conn,
 error:
 	rsp.dcid = 0;
 	rsp.scid = cpu_to_le16(scid);
-	rsp.result = __constant_cpu_to_le16(L2CAP_CR_BAD_AMP);
-	rsp.status = __constant_cpu_to_le16(L2CAP_CS_NO_INFO);
+	rsp.result = cpu_to_le16(L2CAP_CR_BAD_AMP);
+	rsp.status = cpu_to_le16(L2CAP_CS_NO_INFO);
 
 	l2cap_send_cmd(conn, cmd->ident, L2CAP_CREATE_CHAN_RSP,
 		       sizeof(rsp), &rsp);
@@ -4779,7 +4779,7 @@ static void l2cap_send_move_chan_cfm_icid(struct l2cap_conn *conn, u16 icid)
 	BT_DBG("conn %p, icid 0x%4.4x", conn, icid);
 
 	cfm.icid = cpu_to_le16(icid);
-	cfm.result = __constant_cpu_to_le16(L2CAP_MC_UNCONFIRMED);
+	cfm.result = cpu_to_le16(L2CAP_MC_UNCONFIRMED);
 
 	l2cap_send_cmd(conn, l2cap_get_ident(conn), L2CAP_MOVE_CHAN_CFM,
 		       sizeof(cfm), &cfm);
@@ -4962,12 +4962,12 @@ static void l2cap_do_create(struct l2cap_chan *chan, int result,
 
 		if (result == L2CAP_CR_SUCCESS) {
 			/* Send successful response */
-			rsp.result = __constant_cpu_to_le16(L2CAP_CR_SUCCESS);
-			rsp.status = __constant_cpu_to_le16(L2CAP_CS_NO_INFO);
+			rsp.result = cpu_to_le16(L2CAP_CR_SUCCESS);
+			rsp.status = cpu_to_le16(L2CAP_CS_NO_INFO);
 		} else {
 			/* Send negative response */
-			rsp.result = __constant_cpu_to_le16(L2CAP_CR_NO_MEM);
-			rsp.status = __constant_cpu_to_le16(L2CAP_CS_NO_INFO);
+			rsp.result = cpu_to_le16(L2CAP_CR_NO_MEM);
+			rsp.status = cpu_to_le16(L2CAP_CS_NO_INFO);
 		}
 
 		l2cap_send_cmd(chan->conn, chan->ident, L2CAP_CREATE_CHAN_RSP,
@@ -5095,7 +5095,7 @@ static inline int l2cap_move_channel_req(struct l2cap_conn *conn,
 	chan = l2cap_get_chan_by_dcid(conn, icid);
 	if (!chan) {
 		rsp.icid = cpu_to_le16(icid);
-		rsp.result = __constant_cpu_to_le16(L2CAP_MR_NOT_ALLOWED);
+		rsp.result = cpu_to_le16(L2CAP_MR_NOT_ALLOWED);
 		l2cap_send_cmd(conn, cmd->ident, L2CAP_MOVE_CHAN_RSP,
 			       sizeof(rsp), &rsp);
 		return 0;
@@ -5439,9 +5439,9 @@ static inline int l2cap_conn_param_update_req(struct l2cap_conn *conn,
 
 	err = l2cap_check_conn_param(min, max, latency, to_multiplier);
 	if (err)
-		rsp.result = __constant_cpu_to_le16(L2CAP_CONN_PARAM_REJECTED);
+		rsp.result = cpu_to_le16(L2CAP_CONN_PARAM_REJECTED);
 	else
-		rsp.result = __constant_cpu_to_le16(L2CAP_CONN_PARAM_ACCEPTED);
+		rsp.result = cpu_to_le16(L2CAP_CONN_PARAM_ACCEPTED);
 
 	l2cap_send_cmd(conn, cmd->ident, L2CAP_CONN_PARAM_UPDATE_RSP,
 		       sizeof(rsp), &rsp);
@@ -5854,7 +5854,7 @@ static inline void l2cap_le_sig_channel(struct l2cap_conn *conn,
 
 		BT_ERR("Wrong link type (%d)", err);
 
-		rej.reason = __constant_cpu_to_le16(L2CAP_REJ_NOT_UNDERSTOOD);
+		rej.reason = cpu_to_le16(L2CAP_REJ_NOT_UNDERSTOOD);
 		l2cap_send_cmd(conn, cmd->ident, L2CAP_COMMAND_REJ,
 			       sizeof(rej), &rej);
 	}
@@ -5899,7 +5899,7 @@ static inline void l2cap_sig_channel(struct l2cap_conn *conn,
 
 			BT_ERR("Wrong link type (%d)", err);
 
-			rej.reason = __constant_cpu_to_le16(L2CAP_REJ_NOT_UNDERSTOOD);
+			rej.reason = cpu_to_le16(L2CAP_REJ_NOT_UNDERSTOOD);
 			l2cap_send_cmd(conn, cmd.ident, L2CAP_COMMAND_REJ,
 				       sizeof(rej), &rej);
 		}
diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
index d58f76b..f4f8833 100644
--- a/net/bluetooth/l2cap_sock.c
+++ b/net/bluetooth/l2cap_sock.c
@@ -106,7 +106,7 @@ static int l2cap_sock_bind(struct socket *sock, struct sockaddr *addr, int alen)
 			return -EINVAL;
 		/* We only allow ATT user space socket */
 		if (la.l2_cid &&
-		    la.l2_cid != __constant_cpu_to_le16(L2CAP_CID_ATT))
+		    la.l2_cid != cpu_to_le16(L2CAP_CID_ATT))
 			return -EINVAL;
 	}
 
@@ -204,7 +204,7 @@ static int l2cap_sock_connect(struct socket *sock, struct sockaddr *addr,
 		 * ATT. Anything else is an invalid combination.
 		 */
 		if (chan->scid != L2CAP_CID_ATT ||
-		    la.l2_cid != __constant_cpu_to_le16(L2CAP_CID_ATT))
+		    la.l2_cid != cpu_to_le16(L2CAP_CID_ATT))
 			return -EINVAL;
 
 		/* We don't have the hdev available here to make a
@@ -224,7 +224,7 @@ static int l2cap_sock_connect(struct socket *sock, struct sockaddr *addr,
 			return -EINVAL;
 		/* We only allow ATT user space socket */
 		if (la.l2_cid &&
-		    la.l2_cid != __constant_cpu_to_le16(L2CAP_CID_ATT))
+		    la.l2_cid != cpu_to_le16(L2CAP_CID_ATT))
 			return -EINVAL;
 	}
 
diff --git a/net/bluetooth/mgmt.c b/net/bluetooth/mgmt.c
index a03ca3c..a94499a 100644
--- a/net/bluetooth/mgmt.c
+++ b/net/bluetooth/mgmt.c
@@ -207,7 +207,7 @@ static int cmd_status(struct sock *sk, u16 index, u16 cmd, u8 status)
 
 	hdr = (void *) skb_put(skb, sizeof(*hdr));
 
-	hdr->opcode = __constant_cpu_to_le16(MGMT_EV_CMD_STATUS);
+	hdr->opcode = cpu_to_le16(MGMT_EV_CMD_STATUS);
 	hdr->index = cpu_to_le16(index);
 	hdr->len = cpu_to_le16(sizeof(*ev));
 
@@ -238,7 +238,7 @@ static int cmd_complete(struct sock *sk, u16 index, u16 cmd, u8 status,
 
 	hdr = (void *) skb_put(skb, sizeof(*hdr));
 
-	hdr->opcode = __constant_cpu_to_le16(MGMT_EV_CMD_COMPLETE);
+	hdr->opcode = cpu_to_le16(MGMT_EV_CMD_COMPLETE);
 	hdr->index = cpu_to_le16(index);
 	hdr->len = cpu_to_le16(sizeof(*ev) + rp_len);
 
@@ -264,7 +264,7 @@ static int read_version(struct sock *sk, struct hci_dev *hdev, void *data,
 	BT_DBG("sock %p", sk);
 
 	rp.version = MGMT_VERSION;
-	rp.revision = __constant_cpu_to_le16(MGMT_REVISION);
+	rp.revision = cpu_to_le16(MGMT_REVISION);
 
 	return cmd_complete(sk, MGMT_INDEX_NONE, MGMT_OP_READ_VERSION, 0, &rp,
 			    sizeof(rp));
@@ -288,8 +288,8 @@ static int read_commands(struct sock *sk, struct hci_dev *hdev, void *data,
 	if (!rp)
 		return -ENOMEM;
 
-	rp->num_commands = __constant_cpu_to_le16(num_commands);
-	rp->num_events = __constant_cpu_to_le16(num_events);
+	rp->num_commands = cpu_to_le16(num_commands);
+	rp->num_events = cpu_to_le16(num_events);
 
 	for (i = 0, opcode = rp->opcodes; i < num_commands; i++, opcode++)
 		put_unaligned_le16(mgmt_commands[i], opcode);
@@ -1005,7 +1005,7 @@ static int mgmt_event(u16 event, struct hci_dev *hdev, void *data, u16 data_len,
 	if (hdev)
 		hdr->index = cpu_to_le16(hdev->id);
 	else
-		hdr->index = __constant_cpu_to_le16(MGMT_INDEX_NONE);
+		hdr->index = cpu_to_le16(MGMT_INDEX_NONE);
 	hdr->len = cpu_to_le16(data_len);
 
 	if (data)
@@ -1317,15 +1317,15 @@ static void write_fast_connectable(struct hci_request *req, bool enable)
 		type = PAGE_SCAN_TYPE_INTERLACED;
 
 		/* 160 msec page scan interval */
-		acp.interval = __constant_cpu_to_le16(0x0100);
+		acp.interval = cpu_to_le16(0x0100);
 	} else {
 		type = PAGE_SCAN_TYPE_STANDARD;	/* default */
 
 		/* default 1.28 sec page scan */
-		acp.interval = __constant_cpu_to_le16(0x0800);
+		acp.interval = cpu_to_le16(0x0800);
 	}
 
-	acp.window = __constant_cpu_to_le16(0x0012);
+	acp.window = cpu_to_le16(0x0012);
 
 	if (__cpu_to_le16(hdev->page_scan_interval) != acp.interval ||
 	    __cpu_to_le16(hdev->page_scan_window) != acp.window)
@@ -1362,8 +1362,8 @@ static void enable_advertising(struct hci_request *req)
 	u8 enable = 0x01;
 
 	memset(&cp, 0, sizeof(cp));
-	cp.min_interval = __constant_cpu_to_le16(0x0800);
-	cp.max_interval = __constant_cpu_to_le16(0x0800);
+	cp.min_interval = cpu_to_le16(0x0800);
+	cp.max_interval = cpu_to_le16(0x0800);
 	cp.type = get_adv_type(hdev);
 	cp.own_address_type = hdev->own_addr_type;
 	cp.channel_map = 0x07;
@@ -5012,9 +5012,9 @@ void mgmt_device_found(struct hci_dev *hdev, bdaddr_t *bdaddr, u8 link_type,
 	ev->addr.type = link_to_bdaddr(link_type, addr_type);
 	ev->rssi = rssi;
 	if (cfm_name)
-		ev->flags |= __constant_cpu_to_le32(MGMT_DEV_FOUND_CONFIRM_NAME);
+		ev->flags |= cpu_to_le32(MGMT_DEV_FOUND_CONFIRM_NAME);
 	if (!ssp)
-		ev->flags |= __constant_cpu_to_le32(MGMT_DEV_FOUND_LEGACY_PAIRING);
+		ev->flags |= cpu_to_le32(MGMT_DEV_FOUND_LEGACY_PAIRING);
 
 	if (eir_len > 0)
 		memcpy(ev->eir, eir, eir_len);
diff --git a/net/bluetooth/rfcomm/core.c b/net/bluetooth/rfcomm/core.c
index facd8a7..2470ad4 100644
--- a/net/bluetooth/rfcomm/core.c
+++ b/net/bluetooth/rfcomm/core.c
@@ -718,7 +718,7 @@ static struct rfcomm_session *rfcomm_session_create(bdaddr_t *src,
 
 	bacpy(&addr.l2_bdaddr, dst);
 	addr.l2_family = AF_BLUETOOTH;
-	addr.l2_psm    = __constant_cpu_to_le16(RFCOMM_PSM);
+	addr.l2_psm    = cpu_to_le16(RFCOMM_PSM);
 	addr.l2_cid    = 0;
 	addr.l2_bdaddr_type = BDADDR_BREDR;
 	*err = kernel_connect(sock, (struct sockaddr *) &addr, sizeof(addr), O_NONBLOCK);
@@ -1983,7 +1983,7 @@ static int rfcomm_add_listener(bdaddr_t *ba)
 	/* Bind socket */
 	bacpy(&addr.l2_bdaddr, ba);
 	addr.l2_family = AF_BLUETOOTH;
-	addr.l2_psm    = __constant_cpu_to_le16(RFCOMM_PSM);
+	addr.l2_psm    = cpu_to_le16(RFCOMM_PSM);
 	addr.l2_cid    = 0;
 	addr.l2_bdaddr_type = BDADDR_BREDR;
 	err = kernel_bind(sock, (struct sockaddr *) &addr, sizeof(addr));
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index 24fa396..ab1e6fc 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -676,20 +676,20 @@ static void sco_conn_defer_accept(struct hci_conn *conn, u16 setting)
 		bacpy(&cp.bdaddr, &conn->dst);
 		cp.pkt_type = cpu_to_le16(conn->pkt_type);
 
-		cp.tx_bandwidth   = __constant_cpu_to_le32(0x00001f40);
-		cp.rx_bandwidth   = __constant_cpu_to_le32(0x00001f40);
+		cp.tx_bandwidth   = cpu_to_le32(0x00001f40);
+		cp.rx_bandwidth   = cpu_to_le32(0x00001f40);
 		cp.content_format = cpu_to_le16(setting);
 
 		switch (setting & SCO_AIRMODE_MASK) {
 		case SCO_AIRMODE_TRANSP:
 			if (conn->pkt_type & ESCO_2EV3)
-				cp.max_latency = __constant_cpu_to_le16(0x0008);
+				cp.max_latency = cpu_to_le16(0x0008);
 			else
-				cp.max_latency = __constant_cpu_to_le16(0x000D);
+				cp.max_latency = cpu_to_le16(0x000D);
 			cp.retrans_effort = 0x02;
 			break;
 		case SCO_AIRMODE_CVSD:
-			cp.max_latency = __constant_cpu_to_le16(0xffff);
+			cp.max_latency = cpu_to_le16(0xffff);
 			cp.retrans_effort = 0xff;
 			break;
 		}
diff --git a/net/bluetooth/smp.c b/net/bluetooth/smp.c
index 4500736..ddda37c 100644
--- a/net/bluetooth/smp.c
+++ b/net/bluetooth/smp.c
@@ -154,7 +154,7 @@ static struct sk_buff *smp_build_cmd(struct l2cap_conn *conn, u8 code,
 
 	lh = (struct l2cap_hdr *) skb_put(skb, L2CAP_HDR_SIZE);
 	lh->len = cpu_to_le16(sizeof(code) + dlen);
-	lh->cid = __constant_cpu_to_le16(L2CAP_CID_SMP);
+	lh->cid = cpu_to_le16(L2CAP_CID_SMP);
 
 	memcpy(skb_put(skb, sizeof(code)), &code, sizeof(code));
 
-- 
1.8.1.2.459.gbcd45b4.dirty
