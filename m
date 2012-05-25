From: =?UTF-8?q?Stephen=20R=C3=B6ttger?=
	<stephen.roettger@zero-entropy.de>
Subject: [PATCH] ieee802154: pass source address in dgram_recvmsg
Date: Fri, 25 May 2012 14:14:33 +0200
Message-ID: <1337948073-5280-1-git-send-email-stephen.roettger@zero-entropy.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	=?UTF-8?q?Stephen=20R=C3=B6ttger?=
	<stephen.roettger@zero-entropy.de>
To: dbaryshkov@gmail.com, slapin@ossfans.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch lets dgram_recvmsg fill in the sockaddr struct in
msg->msg_name with the source address of the packet.
This is used by the userland functions recvmsg and recvfrom to get the
senders address.
The patch is based on the devel branch of
git://linux-zigbee.git.sourceforge.net/gitroot/linux-zigbee/kernel

Signed-off-by: Stephen R=C3=B6ttger <stephen.roettger@zero-entropy.de>
---
 net/ieee802154/dgram.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/net/ieee802154/dgram.c b/net/ieee802154/dgram.c
index 7883fa6..d0a6ebc 100644
--- a/net/ieee802154/dgram.c
+++ b/net/ieee802154/dgram.c
@@ -290,6 +290,9 @@ static int dgram_recvmsg(struct kiocb *iocb, struct=
 sock *sk,
 	size_t copied =3D 0;
 	int err =3D -EOPNOTSUPP;
 	struct sk_buff *skb;
+	struct sockaddr_ieee802154 *saddr;
+
+	saddr =3D (struct sockaddr_ieee802154 *)msg->msg_name;
=20
 	skb =3D skb_recv_datagram(sk, flags, noblock, &err);
 	if (!skb)
@@ -308,6 +311,13 @@ static int dgram_recvmsg(struct kiocb *iocb, struc=
t sock *sk,
=20
 	sock_recv_ts_and_drops(msg, sk, skb);
=20
+	if (saddr) {
+		saddr->family =3D AF_IEEE802154;
+		saddr->addr =3D mac_cb(skb)->sa;
+	}
+	if (addr_len)
+		*addr_len =3D sizeof(*saddr);
+
 	if (flags & MSG_TRUNC)
 		copied =3D skb->len;
 done:
--=20
1.7.8
