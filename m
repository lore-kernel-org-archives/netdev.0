From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/2] bluetooth: Use printf extension %pMbt
Date: Fri,  3 Dec 2010 18:33:04 -0800
Message-ID: <b966e9510dec12556a3d1313b026cb2c8281e4d6.1291419007.git.joe@perches.com>
References: <cover.1291419007.git.joe@perches.com>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>,
	"Gustavo F. Padovan" <padovan@profusion.mobi>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1291419007.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Save some text and bss.
Remove function batostr so there's no possibility of bad output.

from the net/bluetooth directory:

$ size built-in.o.*
   text	   data	    bss	    dec	    hex	filename
 293562	  16265	  70088	 379915	  5cc0b	built-in.o.allyesconfig.new
 294619	  16269	  70480	 381368	  5d1b8	built-in.o.allyesconfig.old
  30359	    772	     56	  31187	   79d3	built-in.o.btonly.new
  30555	    776	     92	  31423	   7abf	built-in.o.btonly.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/bluetooth/bnep/core.c   |    3 +--
 net/bluetooth/cmtp/core.c   |    2 +-
 net/bluetooth/hci_conn.c    |    6 +++---
 net/bluetooth/hci_core.c    |    8 ++++----
 net/bluetooth/hci_event.c   |    6 +++---
 net/bluetooth/hci_sysfs.c   |   10 +++++-----
 net/bluetooth/hidp/core.c   |    4 ++--
 net/bluetooth/l2cap.c       |   19 +++++++++----------
 net/bluetooth/lib.c         |   14 --------------
 net/bluetooth/rfcomm/core.c |   16 ++++++++--------
 net/bluetooth/rfcomm/sock.c |    8 ++++----
 net/bluetooth/rfcomm/tty.c  |    6 +++---
 net/bluetooth/sco.c         |   12 ++++++------
 13 files changed, 49 insertions(+), 65 deletions(-)

diff --git a/net/bluetooth/bnep/core.c b/net/bluetooth/bnep/core.c
index 5868597..3d4530f 100644
--- a/net/bluetooth/bnep/core.c
+++ b/net/bluetooth/bnep/core.c
@@ -199,8 +199,7 @@ static int bnep_ctrl_set_mcfilter(struct bnep_session *s, u8 *data, int len)
 			memcpy(a1, data, ETH_ALEN); data += ETH_ALEN;
 			a2 = data; data += ETH_ALEN;
 
-			BT_DBG("mc filter %s -> %s",
-				batostr((void *) a1), batostr((void *) a2));
+			BT_DBG("mc filter %pMbt -> %pMbt", a1, a2);
 
 			#define INCA(a) { int i = 5; while (i >=0 && ++a[i--] == 0); }
 
diff --git a/net/bluetooth/cmtp/core.c b/net/bluetooth/cmtp/core.c
index 8e5f292..f72bca7 100644
--- a/net/bluetooth/cmtp/core.c
+++ b/net/bluetooth/cmtp/core.c
@@ -344,7 +344,7 @@ int cmtp_add_connection(struct cmtp_connadd_req *req, struct socket *sock)
 
 	BT_DBG("mtu %d", session->mtu);
 
-	sprintf(session->name, "%s", batostr(&bt_sk(sock->sk)->dst));
+	sprintf(session->name, "%pMbt", &bt_sk(sock->sk)->dst);
 
 	session->sock  = sock;
 	session->state = BT_CONFIG;
diff --git a/net/bluetooth/hci_conn.c b/net/bluetooth/hci_conn.c
index 0b1e460..d9e3eb3 100644
--- a/net/bluetooth/hci_conn.c
+++ b/net/bluetooth/hci_conn.c
@@ -221,7 +221,7 @@ struct hci_conn *hci_conn_add(struct hci_dev *hdev, int type, bdaddr_t *dst)
 {
 	struct hci_conn *conn;
 
-	BT_DBG("%s dst %s", hdev->name, batostr(dst));
+	BT_DBG("%s dst %pMbt", hdev->name, dst);
 
 	conn = kzalloc(sizeof(struct hci_conn), GFP_ATOMIC);
 	if (!conn)
@@ -325,7 +325,7 @@ struct hci_dev *hci_get_route(bdaddr_t *dst, bdaddr_t *src)
 	struct hci_dev *hdev = NULL;
 	struct list_head *p;
 
-	BT_DBG("%s -> %s", batostr(src), batostr(dst));
+	BT_DBG("%pMbt -> %pMbt", src, dst);
 
 	read_lock_bh(&hci_dev_list_lock);
 
@@ -366,7 +366,7 @@ struct hci_conn *hci_connect(struct hci_dev *hdev, int type, bdaddr_t *dst, __u8
 	struct hci_conn *acl;
 	struct hci_conn *sco;
 
-	BT_DBG("%s dst %s", hdev->name, batostr(dst));
+	BT_DBG("%s dst %pMbt", hdev->name, dst);
 
 	if (!(acl = hci_conn_hash_lookup_ba(hdev, ACL_LINK, dst))) {
 		if (!(acl = hci_conn_add(hdev, ACL_LINK, dst)))
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index bc2a052..47962af 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -338,7 +338,7 @@ struct inquiry_entry *hci_inquiry_cache_lookup(struct hci_dev *hdev, bdaddr_t *b
 	struct inquiry_cache *cache = &hdev->inq_cache;
 	struct inquiry_entry *e;
 
-	BT_DBG("cache %p, %s", cache, batostr(bdaddr));
+	BT_DBG("cache %p, %pMbt", cache, bdaddr);
 
 	for (e = cache->list; e; e = e->next)
 		if (!bacmp(&e->data.bdaddr, bdaddr))
@@ -351,7 +351,7 @@ void hci_inquiry_cache_update(struct hci_dev *hdev, struct inquiry_data *data)
 	struct inquiry_cache *cache = &hdev->inq_cache;
 	struct inquiry_entry *e;
 
-	BT_DBG("cache %p, %s", cache, batostr(&data->bdaddr));
+	BT_DBG("cache %p, %pMbt", cache, &data->bdaddr);
 
 	if (!(e = hci_inquiry_cache_lookup(hdev, &data->bdaddr))) {
 		/* Entry not in the cache. Add new one. */
@@ -1478,8 +1478,8 @@ static inline void hci_acl_tx_to(struct hci_dev *hdev)
 	list_for_each(p, &h->list) {
 		c = list_entry(p, struct hci_conn, list);
 		if (c->type == ACL_LINK && c->sent) {
-			BT_ERR("%s killing stalled ACL connection %s",
-				hdev->name, batostr(&c->dst));
+			BT_ERR("%s killing stalled ACL connection %pMbt",
+			       hdev->name, &c->dst);
 			hci_acl_disconn(c, 0x13);
 		}
 	}
diff --git a/net/bluetooth/hci_event.c b/net/bluetooth/hci_event.c
index 3c1957c..53f833f 100644
--- a/net/bluetooth/hci_event.c
+++ b/net/bluetooth/hci_event.c
@@ -566,7 +566,7 @@ static inline void hci_cs_create_conn(struct hci_dev *hdev, __u8 status)
 
 	conn = hci_conn_hash_lookup_ba(hdev, ACL_LINK, &cp->bdaddr);
 
-	BT_DBG("%s bdaddr %s conn %p", hdev->name, batostr(&cp->bdaddr), conn);
+	BT_DBG("%s bdaddr %pMbt conn %p", hdev->name, &cp->bdaddr, conn);
 
 	if (status) {
 		if (conn && conn->state == BT_CONNECT) {
@@ -984,8 +984,8 @@ static inline void hci_conn_request_evt(struct hci_dev *hdev, struct sk_buff *sk
 	struct hci_ev_conn_request *ev = (void *) skb->data;
 	int mask = hdev->link_mode;
 
-	BT_DBG("%s bdaddr %s type 0x%x", hdev->name,
-					batostr(&ev->bdaddr), ev->link_type);
+	BT_DBG("%s bdaddr %pMbt type 0x%x",
+	       hdev->name, &ev->bdaddr, ev->link_type);
 
 	mask |= hci_proto_connect_ind(hdev, &ev->bdaddr, ev->link_type);
 
diff --git a/net/bluetooth/hci_sysfs.c b/net/bluetooth/hci_sysfs.c
index 5fce3d6..5dac407 100644
--- a/net/bluetooth/hci_sysfs.c
+++ b/net/bluetooth/hci_sysfs.c
@@ -37,7 +37,7 @@ static ssize_t show_link_type(struct device *dev, struct device_attribute *attr,
 static ssize_t show_link_address(struct device *dev, struct device_attribute *attr, char *buf)
 {
 	struct hci_conn *conn = dev_get_drvdata(dev);
-	return sprintf(buf, "%s\n", batostr(&conn->dst));
+	return sprintf(buf, "%pMbt\n", &conn->dst);
 }
 
 static ssize_t show_link_features(struct device *dev, struct device_attribute *attr, char *buf)
@@ -236,7 +236,7 @@ static ssize_t show_class(struct device *dev, struct device_attribute *attr, cha
 static ssize_t show_address(struct device *dev, struct device_attribute *attr, char *buf)
 {
 	struct hci_dev *hdev = dev_get_drvdata(dev);
-	return sprintf(buf, "%s\n", batostr(&hdev->bdaddr));
+	return sprintf(buf, "%pMbt\n", &hdev->bdaddr);
 }
 
 static ssize_t show_features(struct device *dev, struct device_attribute *attr, char *buf)
@@ -404,8 +404,8 @@ static int inquiry_cache_show(struct seq_file *f, void *p)
 
 	for (e = cache->list; e; e = e->next) {
 		struct inquiry_data *data = &e->data;
-		seq_printf(f, "%s %d %d %d 0x%.2x%.2x%.2x 0x%.4x %d %d %u\n",
-			   batostr(&data->bdaddr),
+		seq_printf(f, "%pMbt %d %d %d 0x%.2x%.2x%.2x 0x%.4x %d %d %u\n",
+			   &data->bdaddr,
 			   data->pscan_rep_mode, data->pscan_period_mode,
 			   data->pscan_mode, data->dev_class[2],
 			   data->dev_class[1], data->dev_class[0],
@@ -442,7 +442,7 @@ static int blacklist_show(struct seq_file *f, void *p)
 
 		b = list_entry(l, struct bdaddr_list, list);
 
-		seq_printf(f, "%s\n", batostr(&b->bdaddr));
+		seq_printf(f, "%pMbt\n", &b->bdaddr);
 	}
 
 	hci_dev_unlock_bh(hdev);
diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
index 29544c2..cde8827 100644
--- a/net/bluetooth/hidp/core.c
+++ b/net/bluetooth/hidp/core.c
@@ -787,8 +787,8 @@ static int hidp_setup_hid(struct hidp_session *session,
 	hid->country = req->country;
 
 	strncpy(hid->name, req->name, 128);
-	strncpy(hid->phys, batostr(&bt_sk(session->ctrl_sock->sk)->src), 64);
-	strncpy(hid->uniq, batostr(&bt_sk(session->ctrl_sock->sk)->dst), 64);
+	snprintf(hid->phys, 64, "%pMbt", &bt_sk(session->ctrl_sock->sk)->src);
+	snprintf(hid->uniq, 64, "%pMbt", &bt_sk(session->ctrl_sock->sk)->dst);
 
 	hid->dev.parent = hidp_get_device(session);
 	hid->ll_driver = &hidp_hid_driver;
diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 12b4aa2..72b8306 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -1057,8 +1057,7 @@ static int l2cap_do_connect(struct sock *sk)
 	__u8 auth_type;
 	int err;
 
-	BT_DBG("%s -> %s psm 0x%2.2x", batostr(src), batostr(dst),
-							l2cap_pi(sk)->psm);
+	BT_DBG("%pMbt -> %pMbt psm 0x%2.2x", src, dst, l2cap_pi(sk)->psm);
 
 	hdev = hci_get_route(dst, src);
 	if (!hdev)
@@ -4525,7 +4524,7 @@ static int l2cap_connect_ind(struct hci_dev *hdev, bdaddr_t *bdaddr, u8 type)
 	if (type != ACL_LINK)
 		return -EINVAL;
 
-	BT_DBG("hdev %s, bdaddr %s", hdev->name, batostr(bdaddr));
+	BT_DBG("hdev %s, bdaddr %pMbt", hdev->name, bdaddr);
 
 	/* Find listening sockets and check their link_mode */
 	read_lock(&l2cap_sk_list.lock);
@@ -4553,7 +4552,7 @@ static int l2cap_connect_cfm(struct hci_conn *hcon, u8 status)
 {
 	struct l2cap_conn *conn;
 
-	BT_DBG("hcon %p bdaddr %s status %d", hcon, batostr(&hcon->dst), status);
+	BT_DBG("hcon %p bdaddr %pMbt status %d", hcon, &hcon->dst, status);
 
 	if (hcon->type != ACL_LINK)
 		return -EINVAL;
@@ -4798,12 +4797,12 @@ static int l2cap_debugfs_show(struct seq_file *f, void *p)
 	sk_for_each(sk, node, &l2cap_sk_list.head) {
 		struct l2cap_pinfo *pi = l2cap_pi(sk);
 
-		seq_printf(f, "%s %s %d %d 0x%4.4x 0x%4.4x %d %d %d\n",
-					batostr(&bt_sk(sk)->src),
-					batostr(&bt_sk(sk)->dst),
-					sk->sk_state, __le16_to_cpu(pi->psm),
-					pi->scid, pi->dcid,
-					pi->imtu, pi->omtu, pi->sec_level);
+		seq_printf(f, "%pMbt %pMbt %d %d 0x%4.4x 0x%4.4x %d %d %d\n",
+			   &bt_sk(sk)->src,
+			   &bt_sk(sk)->dst,
+			   sk->sk_state, __le16_to_cpu(pi->psm),
+			   pi->scid, pi->dcid,
+			   pi->imtu, pi->omtu, pi->sec_level);
 	}
 
 	read_unlock_bh(&l2cap_sk_list.lock);
diff --git a/net/bluetooth/lib.c b/net/bluetooth/lib.c
index b826d1b..bfc8bbb 100644
--- a/net/bluetooth/lib.c
+++ b/net/bluetooth/lib.c
@@ -44,20 +44,6 @@ void baswap(bdaddr_t *dst, bdaddr_t *src)
 }
 EXPORT_SYMBOL(baswap);
 
-char *batostr(bdaddr_t *ba)
-{
-	static char str[2][18];
-	static int i = 1;
-
-	i ^= 1;
-	sprintf(str[i], "%2.2X:%2.2X:%2.2X:%2.2X:%2.2X:%2.2X",
-		ba->b[5], ba->b[4], ba->b[3],
-		ba->b[2], ba->b[1], ba->b[0]);
-
-	return str[i];
-}
-EXPORT_SYMBOL(batostr);
-
 /* Bluetooth error codes to Unix errno mapping */
 int bt_err(__u16 code)
 {
diff --git a/net/bluetooth/rfcomm/core.c b/net/bluetooth/rfcomm/core.c
index fa642aa..532e5ad 100644
--- a/net/bluetooth/rfcomm/core.c
+++ b/net/bluetooth/rfcomm/core.c
@@ -393,8 +393,8 @@ static int __rfcomm_dlc_open(struct rfcomm_dlc *d, bdaddr_t *src, bdaddr_t *dst,
 	int err = 0;
 	u8 dlci;
 
-	BT_DBG("dlc %p state %ld %s %s channel %d",
-			d, d->state, batostr(src), batostr(dst), channel);
+	BT_DBG("dlc %p state %ld %pMbt %pMbt channel %d",
+	       d, d->state, src, dst, channel);
 
 	if (channel < 1 || channel > 30)
 		return -EINVAL;
@@ -692,7 +692,7 @@ static struct rfcomm_session *rfcomm_session_create(bdaddr_t *src,
 	struct socket *sock;
 	struct sock *sk;
 
-	BT_DBG("%s %s", batostr(src), batostr(dst));
+	BT_DBG("%pMbt %pMbt", src, dst);
 
 	*err = rfcomm_l2sock_create(&sock);
 	if (*err < 0)
@@ -2120,11 +2120,11 @@ static int rfcomm_dlc_debugfs_show(struct seq_file *f, void *x)
 			struct sock *sk = s->sock->sk;
 			struct rfcomm_dlc *d = list_entry(pp, struct rfcomm_dlc, list);
 
-			seq_printf(f, "%s %s %ld %d %d %d %d\n",
-						batostr(&bt_sk(sk)->src),
-						batostr(&bt_sk(sk)->dst),
-						d->state, d->dlci, d->mtu,
-						d->rx_credits, d->tx_credits);
+			seq_printf(f, "%pMbt %pMbt %ld %d %d %d %d\n",
+				   &bt_sk(sk)->src,
+				   &bt_sk(sk)->dst,
+				   d->state, d->dlci, d->mtu,
+				   d->rx_credits, d->tx_credits);
 		}
 	}
 
diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
index 0207bd6..bbbc7479 100644
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -350,7 +350,7 @@ static int rfcomm_sock_bind(struct socket *sock, struct sockaddr *addr, int addr
 	struct sock *sk = sock->sk;
 	int err = 0;
 
-	BT_DBG("sk %p %s", sk, batostr(&sa->rc_bdaddr));
+	BT_DBG("sk %p %pMbt", sk, &sa->rc_bdaddr);
 
 	if (!addr || addr->sa_family != AF_BLUETOOTH)
 		return -EINVAL;
@@ -979,9 +979,9 @@ static int rfcomm_sock_debugfs_show(struct seq_file *f, void *p)
 	read_lock_bh(&rfcomm_sk_list.lock);
 
 	sk_for_each(sk, node, &rfcomm_sk_list.head) {
-		seq_printf(f, "%s %s %d %d\n",
-				batostr(&bt_sk(sk)->src),
-				batostr(&bt_sk(sk)->dst),
+		seq_printf(f, "%pMbt %pMbt %d %d\n",
+				&bt_sk(sk)->src,
+				&bt_sk(sk)->dst,
 				sk->sk_state, rfcomm_pi(sk)->channel);
 	}
 
diff --git a/net/bluetooth/rfcomm/tty.c b/net/bluetooth/rfcomm/tty.c
index a9b81f5..740c99b 100644
--- a/net/bluetooth/rfcomm/tty.c
+++ b/net/bluetooth/rfcomm/tty.c
@@ -183,7 +183,7 @@ static struct device *rfcomm_get_device(struct rfcomm_dev *dev)
 static ssize_t show_address(struct device *tty_dev, struct device_attribute *attr, char *buf)
 {
 	struct rfcomm_dev *dev = dev_get_drvdata(tty_dev);
-	return sprintf(buf, "%s\n", batostr(&dev->dst));
+	return sprintf(buf, "%pMbt\n", &dev->dst);
 }
 
 static ssize_t show_channel(struct device *tty_dev, struct device_attribute *attr, char *buf)
@@ -685,8 +685,8 @@ static int rfcomm_tty_open(struct tty_struct *tty, struct file *filp)
 	if (!dev)
 		return -ENODEV;
 
-	BT_DBG("dev %p dst %s channel %d opened %d", dev, batostr(&dev->dst),
-				dev->channel, atomic_read(&dev->opened));
+	BT_DBG("dev %p dst %pMbt channel %d opened %d",
+	       dev, &dev->dst, dev->channel, atomic_read(&dev->opened));
 
 	if (atomic_inc_return(&dev->opened) > 1)
 		return 0;
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index 66b9e5c..ac8370e 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -183,7 +183,7 @@ static int sco_connect(struct sock *sk)
 	struct hci_dev  *hdev;
 	int err, type;
 
-	BT_DBG("%s -> %s", batostr(src), batostr(dst));
+	BT_DBG("%pMbt -> %pMbt", src, dst);
 
 	if (!(hdev = hci_get_route(dst, src)))
 		return -EHOSTUNREACH;
@@ -457,7 +457,7 @@ static int sco_sock_bind(struct socket *sock, struct sockaddr *addr, int addr_le
 	bdaddr_t *src = &sa->sco_bdaddr;
 	int err = 0;
 
-	BT_DBG("sk %p %s", sk, batostr(&sa->sco_bdaddr));
+	BT_DBG("sk %p %pMbt", sk, src);
 
 	if (!addr || addr->sa_family != AF_BLUETOOTH)
 		return -EINVAL;
@@ -884,7 +884,7 @@ static int sco_connect_ind(struct hci_dev *hdev, bdaddr_t *bdaddr, __u8 type)
 	if (type != SCO_LINK && type != ESCO_LINK)
 		return -EINVAL;
 
-	BT_DBG("hdev %s, bdaddr %s", hdev->name, batostr(bdaddr));
+	BT_DBG("hdev %s, bdaddr %pMbt", hdev->name, bdaddr);
 
 	/* Find listening sockets */
 	read_lock(&sco_sk_list.lock);
@@ -905,7 +905,7 @@ static int sco_connect_ind(struct hci_dev *hdev, bdaddr_t *bdaddr, __u8 type)
 
 static int sco_connect_cfm(struct hci_conn *hcon, __u8 status)
 {
-	BT_DBG("hcon %p bdaddr %s status %d", hcon, batostr(&hcon->dst), status);
+	BT_DBG("hcon %p bdaddr %pMbt status %d", hcon, &hcon->dst, status);
 
 	if (hcon->type != SCO_LINK && hcon->type != ESCO_LINK)
 		return -EINVAL;
@@ -961,8 +961,8 @@ static int sco_debugfs_show(struct seq_file *f, void *p)
 	read_lock_bh(&sco_sk_list.lock);
 
 	sk_for_each(sk, node, &sco_sk_list.head) {
-		seq_printf(f, "%s %s %d\n", batostr(&bt_sk(sk)->src),
-				batostr(&bt_sk(sk)->dst), sk->sk_state);
+		seq_printf(f, "%pMbt %pMbt %d\n",
+			   &bt_sk(sk)->src, &bt_sk(sk)->dst, sk->sk_state);
 	}
 
 	read_unlock_bh(&sco_sk_list.lock);
-- 
1.7.3.2.245.g03276.dirty
