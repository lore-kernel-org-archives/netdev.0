From: =?Windows-1252?Q?Hans_Schillstr=F6m?=
	<hans.schillstrom@ericsson.com>
Subject: RE: [PATCH] ipvs: Remove unused variable "cs" from ip_vs_leave
 function.
Date: Wed, 19 Oct 2011 11:23:54 +0200
Message-ID: <C8A6796DE7C66C4ABCBC18106CB6C1CC106D903183@ESESSCMS0356.eemea.ericsson.se>
References: <1318967989-14076-1-git-send-email-krzysztof.wilczynski@linux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Krzysztof Wilczynski <krzysztof.wilczynski@linux.com>,
	Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw10.se.ericsson.net ([193.180.251.61]:59248 "EHLO
	mailgw10.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752667Ab1JSJX5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 05:23:57 -0400
In-Reply-To: <1318967989-14076-1-git-send-email-krzysztof.wilczynski@linux.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello
>This is to address the following warning during compilation time:
>
>  net/netfilter/ipvs/ip_vs_core.c: In function =91ip_vs_leave=92:
>  net/netfilter/ipvs/ip_vs_core.c:532: warning: unused variable =91cs=92
>
>This variable is indeed no longer in use.
>
>Signed-off-by: Krzysztof Wilczynski <krzysztof.wilczynski@linux.com>

In my code there is another fix needed as well (todays net-next)
i.e.  usage od cs  "cs =3D ip_vs_set_state(cp, IP_VS_DIR_INPUT, skb, pd=
)"


diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs=
_core.c
index 4f77bb1..a4ef9c6 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -530,7 +530,7 @@ int ip_vs_leave(struct ip_vs_service *svc, struct s=
k_buff *skb,
           a cache_bypass connection entry */
        ipvs =3D net_ipvs(net);
        if (ipvs->sysctl_cache_bypass && svc->fwmark && unicast) {
-               int ret, cs;
+               int ret;
                struct ip_vs_conn *cp;
                unsigned int flags =3D (svc->flags & IP_VS_SVC_F_ONEPAC=
KET &&
                                      iph.protocol =3D=3D IPPROTO_UDP)?
@@ -557,7 +557,7 @@ int ip_vs_leave(struct ip_vs_service *svc, struct s=
k_buff *skb,
                ip_vs_in_stats(cp, skb);
=20
                /* set state */
-               cs =3D ip_vs_set_state(cp, IP_VS_DIR_INPUT, skb, pd);
+               ip_vs_set_state(cp, IP_VS_DIR_INPUT, skb, pd);
=20
                /* transmit the first SYN packet */
                ret =3D cp->packet_xmit(skb, cp, pd->pp);

>---
> net/netfilter/ipvs/ip_vs_core.c |    2 +-
> 1 files changed, 1 insertions(+), 1 deletions(-)
>
>diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_v=
s_core.c
>index 00ea1ad..4f7d89d 100644
>--- a/net/netfilter/ipvs/ip_vs_core.c
>+++ b/net/netfilter/ipvs/ip_vs_core.c
>@@ -529,7 +529,7 @@ int ip_vs_leave(struct ip_vs_service *svc, struct =
sk_buff *skb,
>           a cache_bypass connection entry */
>        ipvs =3D net_ipvs(net);
>        if (ipvs->sysctl_cache_bypass && svc->fwmark && unicast) {
>-               int ret, cs;
>+               int ret;
>                struct ip_vs_conn *cp;
>                unsigned int flags =3D (svc->flags & IP_VS_SVC_F_ONEPA=
CKET &&
>                                      iph.protocol =3D=3D IPPROTO_UDP)=
?
>--
>1.7.7

Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
