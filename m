From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net] ipv6: addrconf: fix Juniper SSL VPN client regression
Date: Sat,  9 Jul 2016 23:13:11 +0200
Message-ID: <1468098791-20420-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Jonas Lippuner <jonas@lippuner.ca>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	=?UTF-8?q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
	<hideaki.yoshifuji@miraclelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:35152 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753021AbcGIVNu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2016 17:13:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Juniper SSL VPN client use a "tun" interface and seems to
be picky about visible changes.to it. Commit cc9da6cc4f56
("ipv6: addrconf: use stable address generator for ARPHRD_NONE")
made such interfaces get an auto-generated IPv6 link local address
by default, similar to most other interface types. This made the
Juniper SSL VPN client fail for unknown reasons.

=46ixing this regression by effectively reverting the behaviour to
what we had before, while keeping the new "addrgenmode random"
feature.

This will cause a regression for any userspace application which
has started to depend on the new behaviour.  But it is still
considered the lesser evil, considering the short period this
behaviour has been default.

Link: https://bugzilla.kernel.org/show_bug.cgi?id=3D121131
=46ixes: cc9da6cc4f56 ("ipv6: addrconf: use stable address generator fo=
r ARPHRD_NONE")
Reported-by: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Reported-and-tested-by: Jonas Lippuner <jonas@lippuner.ca>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E <hideaki.yoshifuji@miraclelinu=
x.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
Valdis,

I know you reported this regression back in April, but I never
saw any answers to Hannes' and mine followup quesions so I forgot
all about it.  Sorry about that.  Could you test this patch and
see if it works for you too?


Bj=C3=B8rn

 net/ipv6/addrconf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 47f837a58e0a..34e80c6aa810 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3120,7 +3120,7 @@ static void addrconf_dev_config(struct net_device=
 *dev)
 	/* this device type has no EUI support */
 	if (dev->type =3D=3D ARPHRD_NONE &&
 	    idev->addr_gen_mode =3D=3D IN6_ADDR_GEN_MODE_EUI64)
-		idev->addr_gen_mode =3D IN6_ADDR_GEN_MODE_RANDOM;
+		idev->addr_gen_mode =3D IN6_ADDR_GEN_MODE_NONE;
=20
 	addrconf_addr_gen(idev, false);
 }
--=20
2.8.1
