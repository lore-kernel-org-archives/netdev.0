From: Mike Galbraith <efault@gmx.de>
Subject: !CONFIG_NET_NS build error, net/core/net_namespace.c
Date: Tue, 24 Feb 2009 14:00:27 +0100
Message-ID: <1235480427.5965.22.camel@marge.simson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Daniel Lezcano <daniel.lezcano@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:54545 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754221AbZBXNAd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2009 08:00:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


  CC      net/core/net_namespace.o
net/core/net_namespace.c: In function =E2=80=98net_ns_init=E2=80=99:
net/core/net_namespace.c:223: error: implicit declaration of function =E2=
=80=98net_alloc_generic=E2=80=99
net/core/net_namespace.c:223: warning: assignment makes pointer from in=
teger without a cast
make[2]: *** [net/core/net_namespace.o] Error 1
make[1]: *** [net/core] Error 2
make: *** [net] Error 2


Impact: fix !CONFIG_NET_NS net/core/net_namespace.c build error

Signed-off-by: Mike Galbraith <efault@gmx.de>

 net/core/net_namespace.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index b0767ab..2adb1a7 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -63,10 +63,6 @@ out_undo:
 	goto out;
 }
=20
-#ifdef CONFIG_NET_NS
-static struct kmem_cache *net_cachep;
-static struct workqueue_struct *netns_wq;
-
 static struct net_generic *net_alloc_generic(void)
 {
 	struct net_generic *ng;
@@ -80,6 +76,10 @@ static struct net_generic *net_alloc_generic(void)
 	return ng;
 }
=20
+#ifdef CONFIG_NET_NS
+static struct kmem_cache *net_cachep;
+static struct workqueue_struct *netns_wq;
+
 static struct net *net_alloc(void)
 {
 	struct net *net =3D NULL;


