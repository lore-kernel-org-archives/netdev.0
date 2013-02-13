From: pablo@netfilter.org
Subject: [PATCH 3/3] netfilter: nf_ct_reasm: fix per-netns sysctl initialization
Date: Wed, 13 Feb 2013 21:38:33 +0100
Message-ID: <1360787913-10335-4-git-send-email-pablo@netfilter.org>
References: <1360787913-10335-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from slan-550-85.anhosting.com ([209.236.71.68]:13914 "EHLO
	slan-550-85.anhosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934256Ab3BMUit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2013 15:38:49 -0500
In-Reply-To: <1360787913-10335-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Michal Kube=C4=8Dek <mkubecek@suse.cz>

Adjusting of data pointers in net/netfilter/nf_conntrack_frag6_*
sysctl table for other namespaces points to wrong netns_frags
structure and has reversed order of entries.

Problem introduced by commit c038a767cd69 in 3.7-rc1

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv6/netfilter/nf_conntrack_reasm.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilt=
er/nf_conntrack_reasm.c
index 3dacecc..0156d07 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -97,9 +97,9 @@ static int nf_ct_frag6_sysctl_register(struct net *ne=
t)
 		if (table =3D=3D NULL)
 			goto err_alloc;
=20
-		table[0].data =3D &net->ipv6.frags.high_thresh;
-		table[1].data =3D &net->ipv6.frags.low_thresh;
-		table[2].data =3D &net->ipv6.frags.timeout;
+		table[0].data =3D &net->nf_frag.frags.timeout;
+		table[1].data =3D &net->nf_frag.frags.low_thresh;
+		table[2].data =3D &net->nf_frag.frags.high_thresh;
 	}
=20
 	hdr =3D register_net_sysctl(net, "net/netfilter", table);
--=20
1.7.10.4
