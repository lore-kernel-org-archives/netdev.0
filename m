From: =?UTF-8?q?Vincent=20Stehl=C3=A9?= <vincent.stehle@laposte.net>
Subject: [PATCH linux-next] ipv6: fix missing braces in ip6_tnl_add_linklocal
Date: Thu, 22 Aug 2013 00:19:57 +0200
Message-ID: <1377123597-26515-1-git-send-email-vincent.stehle@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Vincent=20Stehl=C3=A9?= <vincent.stehle@laposte.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Ding Tianhong <dingtianhong@huawei.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-next@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Braces have been removed by mistake by commit df8372c 'ipv6: fix checkp=
atch
errors in net/ipv6/addrconf.c'.

This fixes the following compilation warning:

  net/ipv6/addrconf.c: In function =E2=80=98addrconf_notify=E2=80=99:
  net/ipv6/addrconf.c:2793:22: warning: =E2=80=98link_dev=E2=80=99 may =
be used uninitialized in this function [-Wmaybe-uninitialized]
  net/ipv6/addrconf.c:2802:21: note: =E2=80=98link_dev=E2=80=99 was dec=
lared here

Signed-off-by: Vincent Stehl=C3=A9 <vincent.stehle@laposte.net>
Cc: David S. Miller <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Ding Tianhong <dingtianhong@huawei.com>
---


Hi,

This can be seen in e.g. Linux next-20130821.

Best regards,

V.


 net/ipv6/addrconf.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 980aa98..b2f2e6d 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2803,10 +2803,11 @@ static void ip6_tnl_add_linklocal(struct inet6_=
dev *idev)
 	struct net *net =3D dev_net(idev->dev);
=20
 	/* first try to inherit the link-local address from the link device *=
/
-	if (idev->dev->iflink)
+	if (idev->dev->iflink) {
 		link_dev =3D __dev_get_by_index(net, idev->dev->iflink);
 		if (link_dev && !ipv6_inherit_linklocal(idev, link_dev))
 			return;
+	}
=20
 	/* then try to inherit it from any device */
 	for_each_netdev(net, link_dev) {
--=20
1.7.10.4
