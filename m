From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 04/64] Bluetooth: Make hci_send_sco() void
Date: Mon, 10 May 2010 11:36:54 +0200
Message-ID: <0d861d8b8edd139a9b291cb262d08dec8dc3922d.1273484095.git.marcel@holtmann.org>
References: <cover.1273484094.git.marcel@holtmann.org>
 <fe1aff710756ac73c455d214845c74e304d0e966.1273484095.git.marcel@holtmann.org>
 <acce90d6a957812081b83ac4d1133e93a43569c6.1273484095.git.marcel@holtmann.org>
 <4f7ac1814ef6f0773e57ffd159a1dd57a3c80521.1273484095.git.marcel@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53433 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752694Ab0EJJij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 05:38:39 -0400
In-Reply-To: <4f7ac1814ef6f0773e57ffd159a1dd57a3c80521.1273484095.git.marcel@holtmann.org>
In-Reply-To: <cover.1273484094.git.marcel@holtmann.org>
References: <cover.1273484094.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Gustavo F. Padovan <padovan@profusion.mobi>

It also removes an unneeded check for the MTU. The check is done before
on sco_send_frame()

Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
Reviewed-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@profusion.mobi>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 include/net/bluetooth/hci_core.h |    2 +-
 net/bluetooth/hci_core.c         |    9 +--------
 net/bluetooth/sco.c              |    3 +--
 3 files changed, 3 insertions(+), 11 deletions(-)

diff --git a/include/net/bluetooth/hci_core.h b/include/net/bluetooth/h=
ci_core.h
index ce3c99e..9830a88 100644
--- a/include/net/bluetooth/hci_core.h
+++ b/include/net/bluetooth/hci_core.h
@@ -637,7 +637,7 @@ int hci_unregister_notifier(struct notifier_block *=
nb);
=20
 int hci_send_cmd(struct hci_dev *hdev, __u16 opcode, __u32 plen, void =
*param);
 int hci_send_acl(struct hci_conn *conn, struct sk_buff *skb, __u16 fla=
gs);
-int hci_send_sco(struct hci_conn *conn, struct sk_buff *skb);
+void hci_send_sco(struct hci_conn *conn, struct sk_buff *skb);
=20
 void *hci_sent_cmd_data(struct hci_dev *hdev, __u16 opcode);
=20
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index 4ad2319..1c9aef9 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -1308,18 +1308,13 @@ int hci_send_acl(struct hci_conn *conn, struct =
sk_buff *skb, __u16 flags)
 EXPORT_SYMBOL(hci_send_acl);
=20
 /* Send SCO data */
-int hci_send_sco(struct hci_conn *conn, struct sk_buff *skb)
+void hci_send_sco(struct hci_conn *conn, struct sk_buff *skb)
 {
 	struct hci_dev *hdev =3D conn->hdev;
 	struct hci_sco_hdr hdr;
=20
 	BT_DBG("%s len %d", hdev->name, skb->len);
=20
-	if (skb->len > hdev->sco_mtu) {
-		kfree_skb(skb);
-		return -EINVAL;
-	}
-
 	hdr.handle =3D cpu_to_le16(conn->handle);
 	hdr.dlen   =3D skb->len;
=20
@@ -1332,8 +1327,6 @@ int hci_send_sco(struct hci_conn *conn, struct sk=
_buff *skb)
=20
 	skb_queue_tail(&conn->data_q, skb);
 	tasklet_schedule(&hdev->tx_task);
-
-	return 0;
 }
 EXPORT_SYMBOL(hci_send_sco);
=20
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index b406d3e..541b26e 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -249,8 +249,7 @@ static inline int sco_send_frame(struct sock *sk, s=
truct msghdr *msg, int len)
 		goto fail;
 	}
=20
-	if ((err =3D hci_send_sco(conn->hcon, skb)) < 0)
-		return err;
+	hci_send_sco(conn->hcon, skb);
=20
 	return count;
=20
--=20
1.6.6.1

