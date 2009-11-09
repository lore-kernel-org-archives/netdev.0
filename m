From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: net tree build failure
Date: Mon, 9 Nov 2009 13:21:51 +1100
Message-ID: <20091109132151.0e0ec7bc.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next build (x86_64 allmodconfig) failed like this:

net/appletalk/ddp.c: In function 'atalk_compat_ioctl':
net/appletalk/ddp.c:1866: error: implicit declaration of function 'comp=
at_ptr'

Caused by commit 206602217747382488fcae68351673cc9103debc
("appletalk:=C2=A0handle SIOCATALKDIFADDR compat ioctl").

I applied this patch for today:

=46rom: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 9 Nov 2009 13:11:26 +1100
Subject: [PATCH] net/appletalk: using compat_ptr needs inclusion of lin=
ux/compat.h

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 net/appletalk/ddp.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index b631cc7..73ca4d5 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -56,6 +56,7 @@
 #include <linux/if_arp.h>
 #include <linux/smp_lock.h>
 #include <linux/termios.h>	/* For TIOCOUTQ/INQ */
+#include <linux/compat.h>
 #include <net/datalink.h>
 #include <net/psnap.h>
 #include <net/sock.h>
--=20
1.6.5.2


--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/
