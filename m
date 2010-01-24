From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [2.6.33-rc5 regression] NULL pointer dereference in vlan_skb_recv
 - probably introduced by commit 9793241fe92f7d9303fb221e43fc598eb065f267
Date: Sun, 24 Jan 2010 17:26:39 +0100
Message-ID: <4B5C74BF.5060604@gmail.com>
References: <20100123165657.187c11e4@neptune.home>	<20100123223132.0e62d8cb@neptune.home>	<4B5C4E5E.2010507@gmail.com>	<20100124160228.366f4e72@neptune.home> <20100124162549.2b39b222@neptune.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: =?UTF-8?B?QnJ1bm8gUHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754011Ab0AXQ0t@vger.kernel.org>
In-Reply-To: <20100124162549.2b39b222@neptune.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 24/01/2010 16:25, Bruno Pr=C3=A9mont a =C3=A9crit :
>=20
> In addition to previous mail, I'm also dumping the result of
> vlan_dev_info(dev) shows that the returned pointer is not the same
> during vlan_dev_init() and vlan_skb_recv() ...
>=20

>=20
> This might explain the NULL rx_stats pointer, but why do there exist
> two distinct vlan_dev_info(dev)? (unless in one case dev would be
> the physical network device and in the other case it would be vlan de=
vice?
> that is lan versus lan.658 in my case...)
>=20


Ok, I believe I found the problem :)

Please try following patch, if it works I'll submit with appropriate Ch=
angelog and signatures

Thanks


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
