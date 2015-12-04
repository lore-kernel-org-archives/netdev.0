From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH] ipv6: keep existing flags when setting IFA_F_OPTIMISTIC
Date: Fri,  4 Dec 2015 14:15:08 +0100
Message-ID: <1449234908-29623-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	Erik Kline <ek@google.com>,
	Fernando Gont <fgont@si6networks.com>,
	Lorenzo Colitti <lorenzo@google.com>,
	=?UTF-8?q?YOSHIFUJI=20Hideaki/=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
	<hideaki.yoshifuji@miraclelinux.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:53685 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750817AbbLDNPl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Dec 2015 08:15:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 64236f3f3d74 ("ipv6: introduce IFA_F_STABLE_PRIVACY flag")
failed to update the setting of the IFA_F_OPTIMISTIC flag, causing
the IFA_F_STABLE_PRIVACY flag to be lost if IFA_F_OPTIMISTIC is set.

Cc: Erik Kline <ek@google.com>
Cc: Fernando Gont <fgont@si6networks.com>
Cc: Lorenzo Colitti <lorenzo@google.com>
Cc: YOSHIFUJI Hideaki/=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E <hideaki.yos=
hifuji@miraclelinux.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
=46ixes: 64236f3f3d74 ("ipv6: introduce IFA_F_STABLE_PRIVACY flag")
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 net/ipv6/addrconf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index b5cc81a18521..b3465bbbcd82 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2463,7 +2463,7 @@ ok:
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
 			if (in6_dev->cnf.optimistic_dad &&
 			    !net->ipv6.devconf_all->forwarding && sllao)
-				addr_flags =3D IFA_F_OPTIMISTIC;
+				addr_flags |=3D IFA_F_OPTIMISTIC;
 #endif
=20
 			/* Do not allow to create too much of autoconfigured
--=20
2.1.4
