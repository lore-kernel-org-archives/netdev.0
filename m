From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [GIT PATCH (TAKE 2)] [NET]: Use {htons,htonl,cpu_to_le16}() where
 appropriate.
Date: Wed, 07 Mar 2007 16:08:21 +0900 (JST)
Message-ID: <20070307.160821.77089513.yoshfuji@linux-ipv6.org>
References: <20070307.145807.117077720.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:34389 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964778AbXCGHH7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2007 02:07:59 -0500
In-Reply-To: <20070307.145807.117077720.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

In article <20070307.145807.117077720.yoshfuji@linux-ipv6.org> (at Wed, 07 Mar 2007 14:58:07 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> Please consider pulling following changesets from the
> "net-2.6.22-20070307a-byteorder-20070307" branch at
> <git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev.git>.

Argh, I found more places to convert in bluetooth.

I've made a new branch "net-2.6.22-20070307a-byteorder-20070307a" at
<git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev.git>.

Thanks.

HEADLINES
---------

    [NET] 802: Use hton{s,l}() where appropriate.
    [NET] 8021Q: Use htons() where appropriate.
    [NET] ATM: Use htons() where appropriate.
    [NET] BLUETOOTH: Use cpu_to_le{16,32}() where appropriate.
    [NET] CORE: Use htons() where appropriate.
    [NET] ETHERNET: Use htons() where appropriate.
    [NET] IEEE80211: Use htons() where appropriate.
    [NET] IPV4: Use hton{s,l}() where appropriate.
    [NET] NETFILTER: Use htonl() where appropriate.
    [NET] SCHED: Use htons() where appropriate.
    [NET] TIPC: Use htons() where appropriate.

DIFFSTAT
--------

 net/802/fddi.c                              |    4 +-
 net/802/hippi.c                             |    4 +-
 net/8021q/vlan_dev.c                        |    6 +-
 net/atm/br2684.c                            |    4 +-
 net/bluetooth/hci_conn.c                    |   36 +++++++-------
 net/bluetooth/hci_core.c                    |   20 ++++----
 net/bluetooth/hci_event.c                   |    8 ++-
 net/bluetooth/l2cap.c                       |   70 ++++++++++++++-------------
 net/core/netpoll.c                          |    2 -
 net/ethernet/eth.c                          |    2 -
 net/ieee80211/ieee80211_tx.c                |    2 -
 net/ipv4/ipvs/ip_vs_core.c                  |   10 ++--
 net/ipv4/ipvs/ip_vs_proto_ah.c              |   16 +++---
 net/ipv4/ipvs/ip_vs_xmit.c                  |   16 +++---
 net/ipv4/netfilter/ip_conntrack_proto_tcp.c |    9 ++-
 net/netfilter/nf_conntrack_proto_tcp.c      |    9 ++-
 net/sched/cls_rsvp.h                        |    2 -
 net/sched/sch_api.c                         |    2 -
 net/tipc/eth_media.c                        |    2 -
 19 files changed, 111 insertions(+), 113 deletions(-)

CHANGESETS
----------

commit 9f72aaaed003b2dda0fc5fa28c2caccc4ae358e3
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Mar 7 14:18:33 2007 +0900

    [NET] 802: Use hton{s,l}() where appropriate.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/802/fddi.c b/net/802/fddi.c
index ace6386..8c86216 100644
--- a/net/802/fddi.c
+++ b/net/802/fddi.c
@@ -100,7 +100,7 @@ static int fddi_rebuild_header(struct sk_buff	*skb)
 	struct fddihdr *fddi = (struct fddihdr *)skb->data;
 
 #ifdef CONFIG_INET
-	if (fddi->hdr.llc_snap.ethertype == __constant_htons(ETH_P_IP))
+	if (fddi->hdr.llc_snap.ethertype == htons(ETH_P_IP))
 		/* Try to get ARP to resolve the header and fill destination address */
 		return arp_find(fddi->daddr, skb);
 	else
@@ -135,7 +135,7 @@ __be16 fddi_type_trans(struct sk_buff *skb, struct net_device *dev)
 	if(fddi->hdr.llc_8022_1.dsap==0xe0)
 	{
 		skb_pull(skb, FDDI_K_8022_HLEN-3);
-		type = __constant_htons(ETH_P_802_2);
+		type = htons(ETH_P_802_2);
 	}
 	else
 	{
diff --git a/net/802/hippi.c b/net/802/hippi.c
index 578f2a3..35dd938 100644
--- a/net/802/hippi.c
+++ b/net/802/hippi.c
@@ -60,7 +60,7 @@ static int hippi_header(struct sk_buff *skb, struct net_device *dev,
 	 * Due to the stupidity of the little endian byte-order we
 	 * have to set the fp field this way.
 	 */
-	hip->fp.fixed		= __constant_htonl(0x04800018);
+	hip->fp.fixed		= htonl(0x04800018);
 	hip->fp.d2_size		= htonl(len + 8);
 	hip->le.fc		= 0;
 	hip->le.double_wide	= 0;	/* only HIPPI 800 for the time being */
@@ -104,7 +104,7 @@ static int hippi_rebuild_header(struct sk_buff *skb)
 	 * Only IP is currently supported
 	 */
 
-	if(hip->snap.ethertype != __constant_htons(ETH_P_IP))
+	if(hip->snap.ethertype != htons(ETH_P_IP))
 	{
 		printk(KERN_DEBUG "%s: unable to resolve type %X addresses.\n",skb->dev->name,ntohs(hip->snap.ethertype));
 		return 0;

---
commit d186c0a25b23079f5faac2500d3dcbd8b7d6e166
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Mar 7 14:18:35 2007 +0900

    [NET] 8021Q: Use htons() where appropriate.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 2fc8fe2..e961d59 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -258,7 +258,7 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 	 * won't work for fault tolerant netware but does for the rest.
 	 */
 	if (*(unsigned short *)rawp == 0xFFFF) {
-		skb->protocol = __constant_htons(ETH_P_802_3);
+		skb->protocol = htons(ETH_P_802_3);
 		/* place it back on the queue to be handled by true layer 3 protocols.
 		 */
 
@@ -281,7 +281,7 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 	/*
 	 *	Real 802.2 LLC
 	 */
-	skb->protocol = __constant_htons(ETH_P_802_2);
+	skb->protocol = htons(ETH_P_802_2);
 	/* place it back on the queue to be handled by upper layer protocols.
 	 */
 
@@ -445,7 +445,7 @@ int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * OTHER THINGS LIKE FDDI/TokenRing/802.3 SNAPs...
 	 */
 
-	if (veth->h_vlan_proto != __constant_htons(ETH_P_8021Q)) {
+	if (veth->h_vlan_proto != htons(ETH_P_8021Q)) {
 		int orig_headroom = skb_headroom(skb);
 		unsigned short veth_TCI;
 

---
commit fc0d6e4eca01b7769f5f005687ab70d01421f467
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Mar 7 14:18:40 2007 +0900

    [NET] ATM: Use htons() where appropriate.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index ec4ebd3..c444f5e 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -375,11 +375,11 @@ packet_fails_filter(__be16 type, struct br2684_vcc *brvcc, struct sk_buff *skb)
 {
 	if (brvcc->filter.netmask == 0)
 		return 0;			/* no filter in place */
-	if (type == __constant_htons(ETH_P_IP) &&
+	if (type == htons(ETH_P_IP) &&
 	    (((struct iphdr *) (skb->data))->daddr & brvcc->filter.
 	     netmask) == brvcc->filter.prefix)
 		return 0;
-	if (type == __constant_htons(ETH_P_ARP))
+	if (type == htons(ETH_P_ARP))
 		return 0;
 	/* TODO: we should probably filter ARPs too.. don't want to have
 	 *   them returning values that don't make sense, or is that ok?

---
commit 45c55d20001016f6c3c08d2e5d665ca5907d554a
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Mar 7 15:13:56 2007 +0900

    [NET] BLUETOOTH: Use cpu_to_le{16,32}() where appropriate.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/bluetooth/hci_conn.c b/net/bluetooth/hci_conn.c
index f3403fd..63980bd 100644
--- a/net/bluetooth/hci_conn.c
+++ b/net/bluetooth/hci_conn.c
@@ -72,11 +72,11 @@ void hci_acl_connect(struct hci_conn *conn)
 			inquiry_entry_age(ie) <= INQUIRY_ENTRY_AGE_MAX) {
 		cp.pscan_rep_mode = ie->data.pscan_rep_mode;
 		cp.pscan_mode     = ie->data.pscan_mode;
-		cp.clock_offset   = ie->data.clock_offset | __cpu_to_le16(0x8000);
+		cp.clock_offset   = ie->data.clock_offset | cpu_to_le16(0x8000);
 		memcpy(conn->dev_class, ie->data.dev_class, 3);
 	}
 
-	cp.pkt_type = __cpu_to_le16(hdev->pkt_type & ACL_PTYPE_MASK);
+	cp.pkt_type = cpu_to_le16(hdev->pkt_type & ACL_PTYPE_MASK);
 	if (lmp_rswitch_capable(hdev) && !(hdev->link_mode & HCI_LM_MASTER))
 		cp.role_switch	= 0x01;
 	else
@@ -107,7 +107,7 @@ void hci_acl_disconn(struct hci_conn *conn, __u8 reason)
 
 	conn->state = BT_DISCONN;
 
-	cp.handle = __cpu_to_le16(conn->handle);
+	cp.handle = cpu_to_le16(conn->handle);
 	cp.reason = reason;
 	hci_send_cmd(conn->hdev, OGF_LINK_CTL,
 				OCF_DISCONNECT, sizeof(cp), &cp);
@@ -123,8 +123,8 @@ void hci_add_sco(struct hci_conn *conn, __u16 handle)
 	conn->state = BT_CONNECT;
 	conn->out = 1;
 
-	cp.pkt_type = __cpu_to_le16(hdev->pkt_type & SCO_PTYPE_MASK);
-	cp.handle   = __cpu_to_le16(handle);
+	cp.pkt_type = cpu_to_le16(hdev->pkt_type & SCO_PTYPE_MASK);
+	cp.handle   = cpu_to_le16(handle);
 
 	hci_send_cmd(hdev, OGF_LINK_CTL, OCF_ADD_SCO, sizeof(cp), &cp);
 }
@@ -348,7 +348,7 @@ int hci_conn_auth(struct hci_conn *conn)
 
 	if (!test_and_set_bit(HCI_CONN_AUTH_PEND, &conn->pend)) {
 		struct hci_cp_auth_requested cp;
-		cp.handle = __cpu_to_le16(conn->handle);
+		cp.handle = cpu_to_le16(conn->handle);
 		hci_send_cmd(conn->hdev, OGF_LINK_CTL, OCF_AUTH_REQUESTED, sizeof(cp), &cp);
 	}
 	return 0;
@@ -368,7 +368,7 @@ int hci_conn_encrypt(struct hci_conn *conn)
 
 	if (hci_conn_auth(conn)) {
 		struct hci_cp_set_conn_encrypt cp;
-		cp.handle  = __cpu_to_le16(conn->handle);
+		cp.handle  = cpu_to_le16(conn->handle);
 		cp.encrypt = 1;
 		hci_send_cmd(conn->hdev, OGF_LINK_CTL, OCF_SET_CONN_ENCRYPT, sizeof(cp), &cp);
 	}
@@ -383,7 +383,7 @@ int hci_conn_change_link_key(struct hci_conn *conn)
 
 	if (!test_and_set_bit(HCI_CONN_AUTH_PEND, &conn->pend)) {
 		struct hci_cp_change_conn_link_key cp;
-		cp.handle = __cpu_to_le16(conn->handle);
+		cp.handle = cpu_to_le16(conn->handle);
 		hci_send_cmd(conn->hdev, OGF_LINK_CTL, OCF_CHANGE_CONN_LINK_KEY, sizeof(cp), &cp);
 	}
 	return 0;
@@ -423,7 +423,7 @@ void hci_conn_enter_active_mode(struct hci_conn *conn)
 
 	if (!test_and_set_bit(HCI_CONN_MODE_CHANGE_PEND, &conn->pend)) {
 		struct hci_cp_exit_sniff_mode cp;
-		cp.handle = __cpu_to_le16(conn->handle);
+		cp.handle = cpu_to_le16(conn->handle);
 		hci_send_cmd(hdev, OGF_LINK_POLICY,
 				OCF_EXIT_SNIFF_MODE, sizeof(cp), &cp);
 	}
@@ -452,21 +452,21 @@ void hci_conn_enter_sniff_mode(struct hci_conn *conn)
 
 	if (lmp_sniffsubr_capable(hdev) && lmp_sniffsubr_capable(conn)) {
 		struct hci_cp_sniff_subrate cp;
-		cp.handle             = __cpu_to_le16(conn->handle);
-		cp.max_latency        = __constant_cpu_to_le16(0);
-		cp.min_remote_timeout = __constant_cpu_to_le16(0);
-		cp.min_local_timeout  = __constant_cpu_to_le16(0);
+		cp.handle             = cpu_to_le16(conn->handle);
+		cp.max_latency        = cpu_to_le16(0);
+		cp.min_remote_timeout = cpu_to_le16(0);
+		cp.min_local_timeout  = cpu_to_le16(0);
 		hci_send_cmd(hdev, OGF_LINK_POLICY,
 				OCF_SNIFF_SUBRATE, sizeof(cp), &cp);
 	}
 
 	if (!test_and_set_bit(HCI_CONN_MODE_CHANGE_PEND, &conn->pend)) {
 		struct hci_cp_sniff_mode cp;
-		cp.handle       = __cpu_to_le16(conn->handle);
-		cp.max_interval = __cpu_to_le16(hdev->sniff_max_interval);
-		cp.min_interval = __cpu_to_le16(hdev->sniff_min_interval);
-		cp.attempt      = __constant_cpu_to_le16(4);
-		cp.timeout      = __constant_cpu_to_le16(1);
+		cp.handle       = cpu_to_le16(conn->handle);
+		cp.max_interval = cpu_to_le16(hdev->sniff_max_interval);
+		cp.min_interval = cpu_to_le16(hdev->sniff_min_interval);
+		cp.attempt      = cpu_to_le16(4);
+		cp.timeout      = cpu_to_le16(1);
 		hci_send_cmd(hdev, OGF_LINK_POLICY,
 				OCF_SNIFF_MODE, sizeof(cp), &cp);
 	}
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index 4917919..64fea09 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -216,10 +216,10 @@ static void hci_init_req(struct hci_dev *hdev, unsigned long opt)
 	/* Host buffer size */
 	{
 		struct hci_cp_host_buffer_size cp;
-		cp.acl_mtu = __cpu_to_le16(HCI_MAX_ACL_SIZE);
+		cp.acl_mtu = cpu_to_le16(HCI_MAX_ACL_SIZE);
 		cp.sco_mtu = HCI_MAX_SCO_SIZE;
-		cp.acl_max_pkt = __cpu_to_le16(0xffff);
-		cp.sco_max_pkt = __cpu_to_le16(0xffff);
+		cp.acl_max_pkt = cpu_to_le16(0xffff);
+		cp.sco_max_pkt = cpu_to_le16(0xffff);
 		hci_send_cmd(hdev, OGF_HOST_CTL, OCF_HOST_BUFFER_SIZE, sizeof(cp), &cp);
 	}
 #endif
@@ -240,11 +240,11 @@ static void hci_init_req(struct hci_dev *hdev, unsigned long opt)
 	}
 
 	/* Page timeout ~20 secs */
-	param = __cpu_to_le16(0x8000);
+	param = cpu_to_le16(0x8000);
 	hci_send_cmd(hdev, OGF_HOST_CTL, OCF_WRITE_PG_TIMEOUT, 2, &param);
 
 	/* Connection accept timeout ~20 secs */
-	param = __cpu_to_le16(0x7d00);
+	param = cpu_to_le16(0x7d00);
 	hci_send_cmd(hdev, OGF_HOST_CTL, OCF_WRITE_CA_TIMEOUT, 2, &param);
 }
 
@@ -1034,7 +1034,7 @@ int hci_send_cmd(struct hci_dev *hdev, __u16 ogf, __u16 ocf, __u32 plen, void *p
 	}
 
 	hdr = (struct hci_command_hdr *) skb_put(skb, HCI_COMMAND_HDR_SIZE);
-	hdr->opcode = __cpu_to_le16(hci_opcode_pack(ogf, ocf));
+	hdr->opcode = cpu_to_le16(hci_opcode_pack(ogf, ocf));
 	hdr->plen   = plen;
 
 	if (plen)
@@ -1060,7 +1060,7 @@ void *hci_sent_cmd_data(struct hci_dev *hdev, __u16 ogf, __u16 ocf)
 
 	hdr = (void *) hdev->sent_cmd->data;
 
-	if (hdr->opcode != __cpu_to_le16(hci_opcode_pack(ogf, ocf)))
+	if (hdr->opcode != cpu_to_le16(hci_opcode_pack(ogf, ocf)))
 		return NULL;
 
 	BT_DBG("%s ogf 0x%x ocf 0x%x", hdev->name, ogf, ocf);
@@ -1075,8 +1075,8 @@ static void hci_add_acl_hdr(struct sk_buff *skb, __u16 handle, __u16 flags)
 	int len = skb->len;
 
 	hdr = (struct hci_acl_hdr *) skb_push(skb, HCI_ACL_HDR_SIZE);
-	hdr->handle = __cpu_to_le16(hci_handle_pack(handle, flags));
-	hdr->dlen   = __cpu_to_le16(len);
+	hdr->handle = cpu_to_le16(hci_handle_pack(handle, flags));
+	hdr->dlen   = cpu_to_le16(len);
 
 	skb->h.raw = (void *) hdr;
 }
@@ -1140,7 +1140,7 @@ int hci_send_sco(struct hci_conn *conn, struct sk_buff *skb)
 		return -EINVAL;
 	}
 
-	hdr.handle = __cpu_to_le16(conn->handle);
+	hdr.handle = cpu_to_le16(conn->handle);
 	hdr.dlen   = skb->len;
 
 	skb->h.raw = skb_push(skb, HCI_SCO_HDR_SIZE);
diff --git a/net/bluetooth/hci_event.c b/net/bluetooth/hci_event.c
index 936d3fc..447ba71 100644
--- a/net/bluetooth/hci_event.c
+++ b/net/bluetooth/hci_event.c
@@ -783,7 +783,7 @@ static inline void hci_conn_complete_evt(struct hci_dev *hdev, struct sk_buff *s
 		if (conn->type == ACL_LINK && hdev->link_policy) {
 			struct hci_cp_write_link_policy cp;
 			cp.handle = ev->handle;
-			cp.policy = __cpu_to_le16(hdev->link_policy);
+			cp.policy = cpu_to_le16(hdev->link_policy);
 			hci_send_cmd(hdev, OGF_LINK_POLICY,
 				OCF_WRITE_LINK_POLICY, sizeof(cp), &cp);
 		}
@@ -793,8 +793,8 @@ static inline void hci_conn_complete_evt(struct hci_dev *hdev, struct sk_buff *s
 			struct hci_cp_change_conn_ptype cp;
 			cp.handle = ev->handle;
 			cp.pkt_type = (conn->type == ACL_LINK) ?
-				__cpu_to_le16(hdev->pkt_type & ACL_PTYPE_MASK):
-				__cpu_to_le16(hdev->pkt_type & SCO_PTYPE_MASK);
+				cpu_to_le16(hdev->pkt_type & ACL_PTYPE_MASK):
+				cpu_to_le16(hdev->pkt_type & SCO_PTYPE_MASK);
 
 			hci_send_cmd(hdev, OGF_LINK_CTL,
 				OCF_CHANGE_CONN_PTYPE, sizeof(cp), &cp);
@@ -970,7 +970,7 @@ static inline void hci_auth_complete_evt(struct hci_dev *hdev, struct sk_buff *s
 		if (test_bit(HCI_CONN_ENCRYPT_PEND, &conn->pend)) {
 			if (!ev->status) {
 				struct hci_cp_set_conn_encrypt cp;
-				cp.handle  = __cpu_to_le16(conn->handle);
+				cp.handle  = cpu_to_le16(conn->handle);
 				cp.encrypt = 1;
 				hci_send_cmd(conn->hdev, OGF_LINK_CTL,
 					OCF_SET_CONN_ENCRYPT, sizeof(cp), &cp);
diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index e83ee82..162eab6 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -459,8 +459,8 @@ static void __l2cap_sock_close(struct sock *sk, int reason)
 			sk->sk_state = BT_DISCONN;
 			l2cap_sock_set_timer(sk, sk->sk_sndtimeo);
 
-			req.dcid = __cpu_to_le16(l2cap_pi(sk)->dcid);
-			req.scid = __cpu_to_le16(l2cap_pi(sk)->scid);
+			req.dcid = cpu_to_le16(l2cap_pi(sk)->dcid);
+			req.scid = cpu_to_le16(l2cap_pi(sk)->scid);
 			l2cap_send_cmd(conn, l2cap_get_ident(conn),
 					L2CAP_DISCONN_REQ, sizeof(req), &req);
 		} else {
@@ -652,7 +652,7 @@ static int l2cap_do_connect(struct sock *sk)
 		if (sk->sk_type == SOCK_SEQPACKET) {
 			struct l2cap_conn_req req;
 			l2cap_pi(sk)->ident = l2cap_get_ident(conn);
-			req.scid = __cpu_to_le16(l2cap_pi(sk)->scid);
+			req.scid = cpu_to_le16(l2cap_pi(sk)->scid);
 			req.psm  = l2cap_pi(sk)->psm;
 			l2cap_send_cmd(conn, l2cap_pi(sk)->ident,
 					L2CAP_CONN_REQ, sizeof(req), &req);
@@ -868,8 +868,8 @@ static inline int l2cap_do_send(struct sock *sk, struct msghdr *msg, int len)
 
 	/* Create L2CAP header */
 	lh = (struct l2cap_hdr *) skb_put(skb, L2CAP_HDR_SIZE);
-	lh->cid = __cpu_to_le16(l2cap_pi(sk)->dcid);
-	lh->len = __cpu_to_le16(len + (hlen - L2CAP_HDR_SIZE));
+	lh->cid = cpu_to_le16(l2cap_pi(sk)->dcid);
+	lh->len = cpu_to_le16(len + (hlen - L2CAP_HDR_SIZE));
 
 	if (sk->sk_type == SOCK_DGRAM)
 		put_unaligned(l2cap_pi(sk)->psm, (u16 *) skb_put(skb, 2));
@@ -1096,7 +1096,7 @@ static void l2cap_conn_ready(struct l2cap_conn *conn)
 		} else if (sk->sk_state == BT_CONNECT) {
 			struct l2cap_conn_req req;
 			l2cap_pi(sk)->ident = l2cap_get_ident(conn);
-			req.scid = __cpu_to_le16(l2cap_pi(sk)->scid);
+			req.scid = cpu_to_le16(l2cap_pi(sk)->scid);
 			req.psm  = l2cap_pi(sk)->psm;
 			l2cap_send_cmd(conn, l2cap_pi(sk)->ident, L2CAP_CONN_REQ, sizeof(req), &req);
 		}
@@ -1192,13 +1192,13 @@ static struct sk_buff *l2cap_build_cmd(struct l2cap_conn *conn,
 		return NULL;
 
 	lh = (struct l2cap_hdr *) skb_put(skb, L2CAP_HDR_SIZE);
-	lh->len = __cpu_to_le16(L2CAP_CMD_HDR_SIZE + dlen);
-	lh->cid = __cpu_to_le16(0x0001);
+	lh->len = cpu_to_le16(L2CAP_CMD_HDR_SIZE + dlen);
+	lh->cid = cpu_to_le16(0x0001);
 
 	cmd = (struct l2cap_cmd_hdr *) skb_put(skb, L2CAP_CMD_HDR_SIZE);
 	cmd->code  = code;
 	cmd->ident = ident;
-	cmd->len   = __cpu_to_le16(dlen);
+	cmd->len   = cpu_to_le16(dlen);
 
 	if (dlen) {
 		count -= L2CAP_HDR_SIZE + L2CAP_CMD_HDR_SIZE;
@@ -1316,11 +1316,11 @@ static void l2cap_add_conf_opt(void **ptr, u8 type, u8 len, unsigned long val)
 		break;
 
 	case 2:
-		*((u16 *) opt->val) = __cpu_to_le16(val);
+		*((u16 *) opt->val) = cpu_to_le16(val);
 		break;
 
 	case 4:
-		*((u32 *) opt->val) = __cpu_to_le32(val);
+		*((u32 *) opt->val) = cpu_to_le32(val);
 		break;
 
 	default:
@@ -1346,8 +1346,8 @@ static int l2cap_build_conf_req(struct sock *sk, void *data)
 	//if (flush_to != L2CAP_DEFAULT_FLUSH_TO)
 	//   l2cap_add_conf_opt(&ptr, L2CAP_CONF_FLUSH_TO, 2, pi->flush_to);
 
-	req->dcid  = __cpu_to_le16(pi->dcid);
-	req->flags = __cpu_to_le16(0);
+	req->dcid  = cpu_to_le16(pi->dcid);
+	req->flags = cpu_to_le16(0);
 
 	return ptr - data;
 }
@@ -1383,9 +1383,9 @@ static int l2cap_build_conf_rsp(struct sock *sk, void *data, int *result)
 	else
 		flags = 0x0001;
 
-	rsp->scid   = __cpu_to_le16(l2cap_pi(sk)->dcid);
-	rsp->result = __cpu_to_le16(result ? *result : 0);
-	rsp->flags  = __cpu_to_le16(flags);
+	rsp->scid   = cpu_to_le16(l2cap_pi(sk)->dcid);
+	rsp->result = cpu_to_le16(result ? *result : 0);
+	rsp->flags  = cpu_to_le16(flags);
 
 	return ptr - data;
 }
@@ -1470,10 +1470,10 @@ response:
 	bh_unlock_sock(parent);
 
 sendresp:
-	rsp.scid   = __cpu_to_le16(scid);
-	rsp.dcid   = __cpu_to_le16(dcid);
-	rsp.result = __cpu_to_le16(result);
-	rsp.status = __cpu_to_le16(status);
+	rsp.scid   = cpu_to_le16(scid);
+	rsp.dcid   = cpu_to_le16(dcid);
+	rsp.result = cpu_to_le16(result);
+	rsp.status = cpu_to_le16(status);
 	l2cap_send_cmd(conn, cmd->ident, L2CAP_CONN_RSP, sizeof(rsp), &rsp);
 	return 0;
 }
@@ -1613,8 +1613,8 @@ static inline int l2cap_config_rsp(struct l2cap_conn *conn, struct l2cap_cmd_hdr
 		l2cap_sock_set_timer(sk, HZ * 5);
 		{
 			struct l2cap_disconn_req req;
-			req.dcid = __cpu_to_le16(l2cap_pi(sk)->dcid);
-			req.scid = __cpu_to_le16(l2cap_pi(sk)->scid);
+			req.dcid = cpu_to_le16(l2cap_pi(sk)->dcid);
+			req.scid = cpu_to_le16(l2cap_pi(sk)->scid);
 			l2cap_send_cmd(conn, l2cap_get_ident(conn),
 					L2CAP_DISCONN_REQ, sizeof(req), &req);
 		}
@@ -1652,8 +1652,8 @@ static inline int l2cap_disconnect_req(struct l2cap_conn *conn, struct l2cap_cmd
 	if (!(sk = l2cap_get_chan_by_scid(&conn->chan_list, dcid)))
 		return 0;
 
-	rsp.dcid = __cpu_to_le16(l2cap_pi(sk)->scid);
-	rsp.scid = __cpu_to_le16(l2cap_pi(sk)->dcid);
+	rsp.dcid = cpu_to_le16(l2cap_pi(sk)->scid);
+	rsp.scid = cpu_to_le16(l2cap_pi(sk)->dcid);
 	l2cap_send_cmd(conn, cmd->ident, L2CAP_DISCONN_RSP, sizeof(rsp), &rsp);
 
 	sk->sk_shutdown = SHUTDOWN_MASK;
@@ -1696,8 +1696,8 @@ static inline int l2cap_information_req(struct l2cap_conn *conn, struct l2cap_cm
 
 	BT_DBG("type 0x%4.4x", type);
 
-	rsp.type   = __cpu_to_le16(type);
-	rsp.result = __cpu_to_le16(L2CAP_IR_NOTSUPP);
+	rsp.type   = cpu_to_le16(type);
+	rsp.result = cpu_to_le16(L2CAP_IR_NOTSUPP);
 	l2cap_send_cmd(conn, cmd->ident, L2CAP_INFO_RSP, sizeof(rsp), &rsp);
 
 	return 0;
@@ -1794,7 +1794,7 @@ static inline void l2cap_sig_channel(struct l2cap_conn *conn, struct sk_buff *sk
 			BT_DBG("error %d", err);
 
 			/* FIXME: Map err to a valid reason */
-			rej.reason = __cpu_to_le16(0);
+			rej.reason = cpu_to_le16(0);
 			l2cap_send_cmd(conn, cmd.ident, L2CAP_COMMAND_REJ, sizeof(rej), &rej);
 		}
 
@@ -1993,10 +1993,10 @@ static int l2cap_auth_cfm(struct hci_conn *hcon, u8 status)
 			result = L2CAP_CR_SEC_BLOCK;
 		}
 
-		rsp.scid   = __cpu_to_le16(l2cap_pi(sk)->dcid);
-		rsp.dcid   = __cpu_to_le16(l2cap_pi(sk)->scid);
-		rsp.result = __cpu_to_le16(result);
-		rsp.status = __cpu_to_le16(0);
+		rsp.scid   = cpu_to_le16(l2cap_pi(sk)->dcid);
+		rsp.dcid   = cpu_to_le16(l2cap_pi(sk)->scid);
+		rsp.result = cpu_to_le16(result);
+		rsp.status = cpu_to_le16(0);
 		l2cap_send_cmd(conn, l2cap_pi(sk)->ident,
 				L2CAP_CONN_RSP, sizeof(rsp), &rsp);
 
@@ -2041,10 +2041,10 @@ static int l2cap_encrypt_cfm(struct hci_conn *hcon, u8 status)
 			result = L2CAP_CR_SEC_BLOCK;
 		}
 
-		rsp.scid   = __cpu_to_le16(l2cap_pi(sk)->dcid);
-		rsp.dcid   = __cpu_to_le16(l2cap_pi(sk)->scid);
-		rsp.result = __cpu_to_le16(result);
-		rsp.status = __cpu_to_le16(0);
+		rsp.scid   = cpu_to_le16(l2cap_pi(sk)->dcid);
+		rsp.dcid   = cpu_to_le16(l2cap_pi(sk)->scid);
+		rsp.result = cpu_to_le16(result);
+		rsp.status = cpu_to_le16(0);
 		l2cap_send_cmd(conn, l2cap_pi(sk)->ident,
 				L2CAP_CONN_RSP, sizeof(rsp), &rsp);
 

---
commit 8cd17be7793833092489f866d6bea46d8807b8a2
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Mar 7 14:18:52 2007 +0900

    [NET] CORE: Use htons() where appropriate.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index da10194..4b22c4b 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -443,7 +443,7 @@ int __netpoll_rx(struct sk_buff *skb)
 		goto out;
 
 	/* check if netpoll clients need ARP */
-	if (skb->protocol == __constant_htons(ETH_P_ARP) &&
+	if (skb->protocol == htons(ETH_P_ARP) &&
 	    atomic_read(&trapped)) {
 		skb_queue_tail(&npi->arp_tx, skb);
 		return 1;

---
commit 54cbea91c6dd6177535c4caad4358c77b9840f1b
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Mar 7 14:19:03 2007 +0900

    [NET] ETHERNET: Use htons() where appropriate.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 7391f55..41c5065 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -228,7 +228,7 @@ int eth_header_cache(struct neighbour *neigh, struct hh_cache *hh)
 	eth = (struct ethhdr *)
 	    (((u8 *) hh->hh_data) + (HH_DATA_OFF(sizeof(*eth))));
 
-	if (type == __constant_htons(ETH_P_802_3))
+	if (type == htons(ETH_P_802_3))
 		return -1;
 
 	eth->h_proto = type;

---
commit b7268c16c6ed9f0807c38b63e9ca644f1c8a4b48
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Mar 7 14:19:05 2007 +0900

    [NET] IEEE80211: Use htons() where appropriate.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ieee80211/ieee80211_tx.c b/net/ieee80211/ieee80211_tx.c
index 0292d63..3fca434 100644
--- a/net/ieee80211/ieee80211_tx.c
+++ b/net/ieee80211/ieee80211_tx.c
@@ -225,7 +225,7 @@ static int ieee80211_classify(struct sk_buff *skb)
 	struct iphdr *ip;
 
 	eth = (struct ethhdr *)skb->data;
-	if (eth->h_proto != __constant_htons(ETH_P_IP))
+	if (eth->h_proto != htons(ETH_P_IP))
 		return 0;
 
 	ip = skb->nh.iph;

---
commit 9590aed296a53f26d6816db892e749f14b311c0d
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Mar 7 14:19:10 2007 +0900

    [NET] IPV4: Use hton{s,l}() where appropriate.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
index 24d7b66..858686d 100644
--- a/net/ipv4/ipvs/ip_vs_core.c
+++ b/net/ipv4/ipvs/ip_vs_core.c
@@ -617,7 +617,7 @@ static int ip_vs_out_icmp(struct sk_buff **pskb, int *related)
 	*related = 1;
 
 	/* reassemble IP fragments */
-	if (skb->nh.iph->frag_off & __constant_htons(IP_MF|IP_OFFSET)) {
+	if (skb->nh.iph->frag_off & htons(IP_MF|IP_OFFSET)) {
 		skb = ip_vs_gather_frags(skb, IP_DEFRAG_VS_OUT);
 		if (!skb)
 			return NF_STOLEN;
@@ -659,7 +659,7 @@ static int ip_vs_out_icmp(struct sk_buff **pskb, int *related)
 		return NF_ACCEPT;
 
 	/* Is the embedded protocol header present? */
-	if (unlikely(cih->frag_off & __constant_htons(IP_OFFSET) &&
+	if (unlikely(cih->frag_off & htons(IP_OFFSET) &&
 		     pp->dont_defrag))
 		return NF_ACCEPT;
 
@@ -755,7 +755,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff **pskb,
 		return NF_ACCEPT;
 
 	/* reassemble IP fragments */
-	if (unlikely(iph->frag_off & __constant_htons(IP_MF|IP_OFFSET) &&
+	if (unlikely(iph->frag_off & htons(IP_MF|IP_OFFSET) &&
 		     !pp->dont_defrag)) {
 		skb = ip_vs_gather_frags(skb, IP_DEFRAG_VS_OUT);
 		if (!skb)
@@ -861,7 +861,7 @@ ip_vs_in_icmp(struct sk_buff **pskb, int *related, unsigned int hooknum)
 	*related = 1;
 
 	/* reassemble IP fragments */
-	if (skb->nh.iph->frag_off & __constant_htons(IP_MF|IP_OFFSET)) {
+	if (skb->nh.iph->frag_off & htons(IP_MF|IP_OFFSET)) {
 		skb = ip_vs_gather_frags(skb,
 					 hooknum == NF_IP_LOCAL_IN ?
 					 IP_DEFRAG_VS_IN : IP_DEFRAG_VS_FWD);
@@ -905,7 +905,7 @@ ip_vs_in_icmp(struct sk_buff **pskb, int *related, unsigned int hooknum)
 		return NF_ACCEPT;
 
 	/* Is the embedded protocol header present? */
-	if (unlikely(cih->frag_off & __constant_htons(IP_OFFSET) &&
+	if (unlikely(cih->frag_off & htons(IP_OFFSET) &&
 		     pp->dont_defrag))
 		return NF_ACCEPT;
 
diff --git a/net/ipv4/ipvs/ip_vs_proto_ah.c b/net/ipv4/ipvs/ip_vs_proto_ah.c
index 8b0505b..a842676 100644
--- a/net/ipv4/ipvs/ip_vs_proto_ah.c
+++ b/net/ipv4/ipvs/ip_vs_proto_ah.c
@@ -52,15 +52,15 @@ ah_conn_in_get(const struct sk_buff *skb,
 	if (likely(!inverse)) {
 		cp = ip_vs_conn_in_get(IPPROTO_UDP,
 				       iph->saddr,
-				       __constant_htons(PORT_ISAKMP),
+				       htons(PORT_ISAKMP),
 				       iph->daddr,
-				       __constant_htons(PORT_ISAKMP));
+				       htons(PORT_ISAKMP));
 	} else {
 		cp = ip_vs_conn_in_get(IPPROTO_UDP,
 				       iph->daddr,
-				       __constant_htons(PORT_ISAKMP),
+				       htons(PORT_ISAKMP),
 				       iph->saddr,
-				       __constant_htons(PORT_ISAKMP));
+				       htons(PORT_ISAKMP));
 	}
 
 	if (!cp) {
@@ -89,15 +89,15 @@ ah_conn_out_get(const struct sk_buff *skb, struct ip_vs_protocol *pp,
 	if (likely(!inverse)) {
 		cp = ip_vs_conn_out_get(IPPROTO_UDP,
 					iph->saddr,
-					__constant_htons(PORT_ISAKMP),
+					htons(PORT_ISAKMP),
 					iph->daddr,
-					__constant_htons(PORT_ISAKMP));
+					htons(PORT_ISAKMP));
 	} else {
 		cp = ip_vs_conn_out_get(IPPROTO_UDP,
 					iph->daddr,
-					__constant_htons(PORT_ISAKMP),
+					htons(PORT_ISAKMP),
 					iph->saddr,
-					__constant_htons(PORT_ISAKMP));
+					htons(PORT_ISAKMP));
 	}
 
 	if (!cp) {
diff --git a/net/ipv4/ipvs/ip_vs_xmit.c b/net/ipv4/ipvs/ip_vs_xmit.c
index e1f77bd..f73c5ac 100644
--- a/net/ipv4/ipvs/ip_vs_xmit.c
+++ b/net/ipv4/ipvs/ip_vs_xmit.c
@@ -178,7 +178,7 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* MTU checking */
 	mtu = dst_mtu(&rt->u.dst);
-	if ((skb->len > mtu) && (iph->frag_off&__constant_htons(IP_DF))) {
+	if ((skb->len > mtu) && (iph->frag_off & htons(IP_DF))) {
 		ip_rt_put(rt);
 		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
 		IP_VS_DBG_RL("ip_vs_bypass_xmit(): frag needed\n");
@@ -245,7 +245,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* MTU checking */
 	mtu = dst_mtu(&rt->u.dst);
-	if ((skb->len > mtu) && (iph->frag_off&__constant_htons(IP_DF))) {
+	if ((skb->len > mtu) && (iph->frag_off & htons(IP_DF))) {
 		ip_rt_put(rt);
 		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
 		IP_VS_DBG_RL_PKT(0, pp, skb, 0, "ip_vs_nat_xmit(): frag needed for");
@@ -329,10 +329,10 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	EnterFunction(10);
 
-	if (skb->protocol != __constant_htons(ETH_P_IP)) {
+	if (skb->protocol != htons(ETH_P_IP)) {
 		IP_VS_DBG_RL("ip_vs_tunnel_xmit(): protocol error, "
 			     "ETH_P_IP: %d, skb protocol: %d\n",
-			     __constant_htons(ETH_P_IP), skb->protocol);
+			     htons(ETH_P_IP), skb->protocol);
 		goto tx_error;
 	}
 
@@ -350,9 +350,9 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	if (skb->dst)
 		skb->dst->ops->update_pmtu(skb->dst, mtu);
 
-	df |= (old_iph->frag_off&__constant_htons(IP_DF));
+	df |= (old_iph->frag_off & htons(IP_DF));
 
-	if ((old_iph->frag_off&__constant_htons(IP_DF))
+	if ((old_iph->frag_off & htons(IP_DF))
 	    && mtu < ntohs(old_iph->tot_len)) {
 		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
 		ip_rt_put(rt);
@@ -445,7 +445,7 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* MTU checking */
 	mtu = dst_mtu(&rt->u.dst);
-	if ((iph->frag_off&__constant_htons(IP_DF)) && skb->len > mtu) {
+	if ((iph->frag_off & htons(IP_DF)) && skb->len > mtu) {
 		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
 		ip_rt_put(rt);
 		IP_VS_DBG_RL("ip_vs_dr_xmit(): frag needed\n");
@@ -519,7 +519,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* MTU checking */
 	mtu = dst_mtu(&rt->u.dst);
-	if ((skb->len > mtu) && (skb->nh.iph->frag_off&__constant_htons(IP_DF))) {
+	if ((skb->len > mtu) && (skb->nh.iph->frag_off & htons(IP_DF))) {
 		ip_rt_put(rt);
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
 		IP_VS_DBG_RL("ip_vs_in_icmp(): frag needed\n");
diff --git a/net/ipv4/netfilter/ip_conntrack_proto_tcp.c b/net/ipv4/netfilter/ip_conntrack_proto_tcp.c
index 170d625..88499df 100644
--- a/net/ipv4/netfilter/ip_conntrack_proto_tcp.c
+++ b/net/ipv4/netfilter/ip_conntrack_proto_tcp.c
@@ -515,11 +515,10 @@ static void tcp_sack(const struct sk_buff *skb,
 
 	/* Fast path for timestamp-only option */
 	if (length == TCPOLEN_TSTAMP_ALIGNED*4
-	    && *(__be32 *)ptr ==
-		__constant_htonl((TCPOPT_NOP << 24)
-				 | (TCPOPT_NOP << 16)
-				 | (TCPOPT_TIMESTAMP << 8)
-				 | TCPOLEN_TIMESTAMP))
+	    && *(__be32 *)ptr == htonl((TCPOPT_NOP << 24)
+				       | (TCPOPT_NOP << 16)
+				       | (TCPOPT_TIMESTAMP << 8)
+				       | TCPOLEN_TIMESTAMP))
 		return;
 
 	while (length > 0) {

---
commit 1e831e2bd69821a09063e03cdc75322d36f34035
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Mar 7 14:21:00 2007 +0900

    [NET] NETFILTER: Use htonl() where appropriate.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 069b85c..f132f75 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -470,11 +470,10 @@ static void tcp_sack(const struct sk_buff *skb, unsigned int dataoff,
 
 	/* Fast path for timestamp-only option */
 	if (length == TCPOLEN_TSTAMP_ALIGNED*4
-	    && *(__be32 *)ptr ==
-		__constant_htonl((TCPOPT_NOP << 24)
-				 | (TCPOPT_NOP << 16)
-				 | (TCPOPT_TIMESTAMP << 8)
-				 | TCPOLEN_TIMESTAMP))
+	    && *(__be32 *)ptr == htonl((TCPOPT_NOP << 24)
+				       | (TCPOPT_NOP << 16)
+				       | (TCPOPT_TIMESTAMP << 8)
+				       | TCPOLEN_TIMESTAMP))
 		return;
 
 	while (length > 0) {

---
commit 3357f8bf3924c302e7c4fa1b561d51ebdcf3ef97
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Mar 7 14:21:20 2007 +0900

    [NET] SCHED: Use htons() where appropriate.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index 7853621..b6ac0e2 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -160,7 +160,7 @@ restart:
 	dst = &nhptr->daddr;
 	protocol = nhptr->protocol;
 	xprt = ((u8*)nhptr) + (nhptr->ihl<<2);
-	if (nhptr->frag_off&__constant_htons(IP_MF|IP_OFFSET))
+	if (nhptr->frag_off & htons(IP_MF|IP_OFFSET))
 		return -1;
 #endif
 
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index ecc988a..4a927a5 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1146,7 +1146,7 @@ reclassify:
 
 	for ( ; tp; tp = tp->next) {
 		if ((tp->protocol == protocol ||
-			tp->protocol == __constant_htons(ETH_P_ALL)) &&
+			tp->protocol == htons(ETH_P_ALL)) &&
 			(err = tp->classify(skb, tp, res)) >= 0) {
 #ifdef CONFIG_NET_CLS_ACT
 			if ( TC_ACT_RECLASSIFY == err) {

---
commit f7b1fac85158cc963e637b919e1322d56c725933
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Mar 7 14:21:31 2007 +0900

    [NET] TIPC: Use htons() where appropriate.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index 9be4839..f71ba9d 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -140,7 +140,7 @@ static int enable_bearer(struct tipc_bearer *tb_ptr)
 		return -EDQUOT;
 	if (!eb_ptr->dev) {
 		eb_ptr->dev = dev;
-		eb_ptr->tipc_packet_type.type = __constant_htons(ETH_P_TIPC);
+		eb_ptr->tipc_packet_type.type = htons(ETH_P_TIPC);
 		eb_ptr->tipc_packet_type.dev = dev;
 		eb_ptr->tipc_packet_type.func = recv_msg;
 		eb_ptr->tipc_packet_type.af_packet_priv = eb_ptr;

---

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
