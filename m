From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Tue, 25 Oct 2011 16:16:10 +0200
Message-ID: <1319552170.10883.19.camel@edumazet-laptop>
References: <20111026005530.a4bd779e1a8182ea57dbf99f@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Linus <torvalds@linux-foundation.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20111026005530.a4bd779e1a8182ea57dbf99f@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 26 octobre 2011 =C3=A0 00:55 +1100, Stephen Rothwell a =C3=A9=
crit :
> Hi all,
>=20
> After merging the net-next tree, today's linux-next build (powerpc
> pseries_defconfig) failed like this:
>=20
> drivers/net/ethernet/ibm/ehea/ehea_main.c: In function 'write_swqe2_d=
ata':
> drivers/net/ethernet/ibm/ehea/ehea_main.c:1692: error: implicit decla=
ration of function 'frag_size'
>=20
> Presumably caused by commit 9e903e085262 ("net: add skb frag size
> accessors").  I guess it should have been "skb_frag_size()".

My bad, sorry

[PATCH] ehea: fix skb_frag_size typo

commit 9e903e085262 (net: add skb frag size accessors) introduced a typ=
o
in ehea driver.

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/ethernet/ibm/ehea/ehea_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/et=
hernet/ibm/ehea/ehea_main.c
index 0d4d4f6..37b70f7 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -1689,7 +1689,7 @@ static inline void write_swqe2_data(struct sk_buf=
f *skb, struct net_device *dev,
 			sgentry =3D &sg_list[i - sg1entry_contains_frag_data];
=20
 			sgentry->l_key =3D lkey;
-			sgentry->len =3D frag_size(frag);
+			sgentry->len =3D skb_frag_size(frag);
 			sgentry->vaddr =3D ehea_map_vaddr(skb_frag_address(frag));
 			swqe->descriptors++;
 		}
