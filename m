From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH] igmp: fix build warning
Date: Tue, 16 Feb 2016 13:52:30 +0530
Message-ID: <1455610950-27802-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Sudip Mukherjee <sudipm.mukherjee@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We were getting build warnings about:
net/ipv4/igmp.c: In function =E2=80=98igmp_group_added=E2=80=99:
net/ipv4/igmp.c:1227:14: warning: unused variable =E2=80=98net=E2=80=99=
 [-Wunused-variable]
	=09
net/ipv4/igmp.c: In function =E2=80=98ip_mc_inc_group=E2=80=99:
net/ipv4/igmp.c:1319:14: warning: unused variable =E2=80=98net=E2=80=99=
 [-Wunused-variable]

net/ipv4/igmp.c: In function =E2=80=98ip_mc_init_dev=E2=80=99:
net/ipv4/igmp.c:1646:14: warning: unused variable =E2=80=98net=E2=80=99=
 [-Wunused-variable]

net/ipv4/igmp.c: In function =E2=80=98ip_mc_up=E2=80=99:
net/ipv4/igmp.c:1665:14: warning: unused variable =E2=80=98net=E2=80=99=
 [-Wunused-variable]

These variables are only used when CONFIG_IP_MULTICAST is defined. Mark
them as '__maybe_unused'.

Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
---
 net/ipv4/igmp.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 7c95335..0ba241b 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1224,7 +1224,7 @@ static void igmp_group_dropped(struct ip_mc_list =
*im)
 static void igmp_group_added(struct ip_mc_list *im)
 {
 	struct in_device *in_dev =3D im->interface;
-	struct net *net =3D dev_net(in_dev->dev);
+	struct net __maybe_unused *net =3D dev_net(in_dev->dev);
=20
 	if (im->loaded =3D=3D 0) {
 		im->loaded =3D 1;
@@ -1316,7 +1316,7 @@ static void ip_mc_hash_remove(struct in_device *i=
n_dev,
 void ip_mc_inc_group(struct in_device *in_dev, __be32 addr)
 {
 	struct ip_mc_list *im;
-	struct net *net =3D dev_net(in_dev->dev);
+	struct net __maybe_unused *net =3D dev_net(in_dev->dev);
=20
 	ASSERT_RTNL();
=20
@@ -1643,7 +1643,7 @@ void ip_mc_down(struct in_device *in_dev)
=20
 void ip_mc_init_dev(struct in_device *in_dev)
 {
-	struct net *net =3D dev_net(in_dev->dev);
+	struct net __maybe_unused *net =3D dev_net(in_dev->dev);
 	ASSERT_RTNL();
=20
 #ifdef CONFIG_IP_MULTICAST
@@ -1662,7 +1662,7 @@ void ip_mc_init_dev(struct in_device *in_dev)
 void ip_mc_up(struct in_device *in_dev)
 {
 	struct ip_mc_list *pmc;
-	struct net *net =3D dev_net(in_dev->dev);
+	struct net __maybe_unused *net =3D dev_net(in_dev->dev);
=20
 	ASSERT_RTNL();
=20
--=20
1.9.1
