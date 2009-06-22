From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 07/07: xt_rateest: fix comparison with self
Date: Mon, 22 Jun 2009 14:53:58 +0200 (MEST)
Message-ID: <20090622125358.6531.72261.sendpatchset@x2.localnet>
References: <20090622125349.6531.35515.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39246 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752609AbZFVMx4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 08:53:56 -0400
In-Reply-To: <20090622125349.6531.35515.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 4d900f9df5f0569c2dc536701e2c11b6d50ebebf
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Jun 22 14:17:12 2009 +0200

    netfilter: xt_rateest: fix comparison with self
   =20
    As noticed by T=F6r=F6k Edwin <edwintorok@gmail.com>:
   =20
    Compiling the kernel with clang has shown this warning:
   =20
    net/netfilter/xt_rateest.c:69:16: warning: self-comparison always r=
esults in a
    constant value
                            ret &=3D pps2 =3D=3D pps2;
                                        ^
    Looking at the code:
    if (info->flags & XT_RATEEST_MATCH_BPS)
                ret &=3D bps1 =3D=3D bps2;
            if (info->flags & XT_RATEEST_MATCH_PPS)
                ret &=3D pps2 =3D=3D pps2;
   =20
    Judging from the MATCH_BPS case it seems to be a typo, with the int=
ention of
    comparing pps1 with pps2.
   =20
    http://bugzilla.kernel.org/show_bug.cgi?id=3D13535
   =20
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/xt_rateest.c b/net/netfilter/xt_rateest.c
index 220a1d5..4fc6a91 100644
--- a/net/netfilter/xt_rateest.c
+++ b/net/netfilter/xt_rateest.c
@@ -66,7 +66,7 @@ xt_rateest_mt(const struct sk_buff *skb, const struct=
 xt_match_param *par)
 		if (info->flags & XT_RATEEST_MATCH_BPS)
 			ret &=3D bps1 =3D=3D bps2;
 		if (info->flags & XT_RATEEST_MATCH_PPS)
-			ret &=3D pps2 =3D=3D pps2;
+			ret &=3D pps1 =3D=3D pps2;
 		break;
 	}
=20
