From: jovi zhang <bookjovi@gmail.com>
Subject: [PATCH] netlink: Fix kfree NULL pointer
Date: Wed, 8 Sep 2010 13:13:57 +0800
Message-ID: <AANLkTikp0m8cQYfEBHP_E8XpGZqdMj6Cr4M=aWCnei=X__36960.4415297092$1283923241$gmane$org@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes.berg@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Alexey Dobriyan
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:56157 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751468Ab0IHFUT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 01:20:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It will kfree NULL pointer if listeners is NULL. fix it.

Signed-off-by: bookjovi@gmail.com
net/netlink/af_netlink.c | =C2=A0 =C2=A05 +++--
1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 980fe4a..1c7bf48 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1532,8 +1532,10 @@ netlink_kernel_create(struct net *net, int
unit, unsigned int groups,
=C2=A0 =C2=A0 =C2=A0 =C2=A0if (input)
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0nlk_sk(sk)->netl=
ink_rcv =3D input;

- =C2=A0 =C2=A0 =C2=A0 if (netlink_insert(sk, net, 0))
+ =C2=A0 =C2=A0 =C2=A0 if (netlink_insert(sk, net, 0)) {
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 kfree(listeners);
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto out_sock_re=
lease;
+ =C2=A0 =C2=A0 =C2=A0 }

=C2=A0 =C2=A0 =C2=A0 =C2=A0nlk =3D nlk_sk(sk);
=C2=A0 =C2=A0 =C2=A0 =C2=A0nlk->flags |=3D NETLINK_KERNEL_SOCKET;
@@ -1553,7 +1555,6 @@ netlink_kernel_create(struct net *net, int unit,
unsigned int groups,
=C2=A0 =C2=A0 =C2=A0 =C2=A0return sk;

out_sock_release:
- =C2=A0 =C2=A0 =C2=A0 kfree(listeners);
=C2=A0 =C2=A0 =C2=A0 =C2=A0netlink_kernel_release(sk);
=C2=A0 =C2=A0 =C2=A0 =C2=A0return NULL;
