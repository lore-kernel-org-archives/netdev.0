From: David Miller <davem@davemloft.net>
Subject: Re: linux- 2.6.17.7 undefined reference to `alloc_ltalkdev'
Date: Sun, 30 Jul 2006 15:54:46 -0700 (PDT)
Message-ID: <20060730.155446.14843504.davem@davemloft.net>
References: <200607292055.13437.toralf.foerster@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:56469
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964779AbWG3Wyg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Jul 2006 18:54:36 -0400
To: toralf.foerster@gmx.de
In-Reply-To: <200607292055.13437.toralf.foerster@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Toralf F=F6rster <toralf.foerster@gmx.de>
Date: Sat, 29 Jul 2006 20:55:11 +0200

> Subject: linux- 2.6.17.7 undefined reference to `alloc_ltalkdev'

Bug is that appletalk is built modular, which is where
alloc_ltalkdev is exported from, but we allow users of
this symbol, such as the cops driver, to be built non-modular.

Luckily the fix is simple, we need to change CONFIG_DEV_APPLETALK
to be a 'tristate' instead of a 'bool'.  The following patch
is what I'll use to fix this bug.

Thanks for the report.

diff-tree 66d3ad53b6867aa1bc499062bd19f85bfeee2f9e (from d0ccba71dfe903=
a737d011d93a076c10cf487b19)
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Sun Jul 30 15:54:11 2006 -0700

    [ATALK]: Make CONFIG_DEV_APPLETALK a tristate.
   =20
    Otherwise we allow building appletalk drivers in-kernel when
    CONFIG_ATALK is modular.  That doesn't work because these drivers u=
se
    symbols such as "alloc_talkdev" which is exported from code built
    by CONFIG_ATALK.
   =20
    Noticed by Toralf F=F6rster.
   =20
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/appletalk/Kconfig b/drivers/net/appletalk/Kcon=
fig
index b14e890..0a0e0cd 100644
--- a/drivers/net/appletalk/Kconfig
+++ b/drivers/net/appletalk/Kconfig
@@ -29,7 +29,7 @@ config ATALK
 	  even politically correct people are allowed to say Y here.
=20
 config DEV_APPLETALK
-	bool "Appletalk interfaces support"
+	tristate "Appletalk interfaces support"
 	depends on ATALK
 	help
 	  AppleTalk is the protocol that Apple computers can use to communica=
te
