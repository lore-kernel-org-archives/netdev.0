From: pablo@netfilter.org
Subject: [PATCH 4/5] netfilter: ip6t_NPT: Fix prefix mangling
Date: Sat,  9 Feb 2013 13:03:59 +0100
Message-ID: <1360411440-6526-5-git-send-email-pablo@netfilter.org>
References: <1360411440-6526-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1360411440-6526-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E <yoshf=
uji@linux-ipv6.org>

Make sure only the bits that are part of the prefix are mangled.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv6/netfilter/ip6t_NPT.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/netfilter/ip6t_NPT.c b/net/ipv6/netfilter/ip6t_NP=
T.c
index 68788c8..87b759c 100644
--- a/net/ipv6/netfilter/ip6t_NPT.c
+++ b/net/ipv6/netfilter/ip6t_NPT.c
@@ -51,7 +51,7 @@ static bool ip6t_npt_map_pfx(const struct ip6t_npt_tg=
info *npt,
=20
 		idx =3D i / 32;
 		addr->s6_addr32[idx] &=3D mask;
-		addr->s6_addr32[idx] |=3D npt->dst_pfx.in6.s6_addr32[idx];
+		addr->s6_addr32[idx] |=3D ~mask & npt->dst_pfx.in6.s6_addr32[idx];
 	}
=20
 	if (pfx_len <=3D 48)
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
