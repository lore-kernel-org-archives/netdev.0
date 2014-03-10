From: Peter =?ISO-8859-1?Q?Bostr=F6m?= <peter.bostrom@netrounds.com>
Subject: [PATCH] vlan: Set correct source MAC address with TX VLAN offload
 enabled
Date: Mon, 10 Mar 2014 16:17:15 +0100
Message-ID: <1394464635.27812.7.camel@peter-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: kaber@trash.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With TX VLAN offload enabled the source MAC address for frames sent usi=
ng the
VLAN interface is currently set to the address of the real interface. T=
his is
wrong since the VLAN interface may be configured with a different addre=
ss.

The bug was introduced in commit 2205369a314e12fcec4781cc73ac9c08fc2b47=
de
("vlan: Fix header ops passthru when doing TX VLAN offload.").

This patch sets the source address before calling the create function o=
f the
real interface.

Signed-off-by: Peter Bostr=C3=B6m <peter.bostrom@netrounds.com>
---
 net/8021q/vlan_dev.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index de51c48..4b65aa4 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -538,6 +538,9 @@ static int vlan_passthru_hard_header(struct sk_buff=
 *skb, struct net_device *dev
 	struct vlan_dev_priv *vlan =3D vlan_dev_priv(dev);
 	struct net_device *real_dev =3D vlan->real_dev;
=20
+	if (saddr =3D=3D NULL)
+		saddr =3D dev->dev_addr;
+
 	return dev_hard_header(skb, real_dev, type, daddr, saddr, len);
 }
=20
