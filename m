From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] vlan: fix vlan_skb_recv()
Date: Sun, 24 Jan 2010 20:43:06 +0100
Message-ID: <4B5CA2CA.4040307@gmail.com>
References: <20100123165657.187c11e4@neptune.home>	<20100123223132.0e62d8cb@neptune.home>	<4B5C4E5E.2010507@gmail.com>	<20100124160228.366f4e72@neptune.home>	<20100124162549.2b39b222@neptune.home>	<4B5C74BF.5060604@gmail.com> <20100124201808.2bbbf0b0@neptune.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?QW3DqXJpY28gV2FuZw==?= <xiyou.wangcong@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: =?UTF-8?B?QnJ1bm8gUHLDqW1vbnQ=?= <bonbons@linux-vserver.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753456Ab0AXTnO@vger.kernel.org>
In-Reply-To: <20100124201808.2bbbf0b0@neptune.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 24/01/2010 20:18, Bruno Pr=C3=A9mont a =C3=A9crit :
> Yep, works fine and RX stats look right as well.
>=20
> So
> Reported-By: Bruno Pr=C3=A9mont <bonbons@linux-vserver.org>
> Tested-By: Bruno Pr=C3=A9mont <bonbons@linux-vserver.org>
>=20
> Thanks,

Thanks very much Bruno, here is the official patch submission then.

[PATCH] vlan: fix vlan_skb_recv()

Bruno Pr=C3=A9mont found commit 9793241fe92f7d930
(vlan: Precise RX stats accounting) added a regression for non
hw accelerated vlans.

[   26.390576] BUG: unable to handle kernel NULL pointer dereference at=
 (null)
[   26.396369] IP: [<df856b89>] vlan_skb_recv+0x89/0x280 [8021q]

vlan_dev_info() was used with original device, instead of
skb->dev. Also spotted by Am=C3=A9rico Wang.

Reported-By: Bruno Pr=C3=A9mont <bonbons@linux-vserver.org>
Tested-By: Bruno Pr=C3=A9mont <bonbons@linux-vserver.org>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/8021q/vlan_dev.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index b788978..c1b92ca 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -163,7 +163,7 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_d=
evice *dev,
 		goto err_unlock;
 	}
=20
-	rx_stats =3D per_cpu_ptr(vlan_dev_info(dev)->vlan_rx_stats,
+	rx_stats =3D per_cpu_ptr(vlan_dev_info(skb->dev)->vlan_rx_stats,
 			       smp_processor_id());
 	rx_stats->rx_packets++;
 	rx_stats->rx_bytes +=3D skb->len;
