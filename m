From: Patrick McHardy <kaber@trash.net>
Subject: netfilter -stable 06/08: xt_rateest: fix comparison with self
Date: Thu, 23 Jul 2009 16:15:32 +0200 (MEST)
Message-ID: <20090723141531.19029.58305.sendpatchset@x2.localnet>
References: <20090723141523.19029.89290.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39731 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752701AbZGWOPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2009 10:15:32 -0400
In-Reply-To: <20090723141523.19029.89290.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 77609e5aca9bc8cd4e9ea960177df1e980b3d040
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Jul 3 10:35:55 2009 +0200

    netfilter: xt_rateest: fix comparison with self
   =20
    Upstream commit 4d900f9df:
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
