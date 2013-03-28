From: Alexandru Copot <alex.mihai.c@gmail.com>
Subject: [PATCH net-next] audit: pass int* to nlmsg_next
Date: Thu, 28 Mar 2013 23:31:29 +0200
Message-ID: <1364506289-9146-1-git-send-email-alex.mihai.c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: honkiko@gmail.com, tgraf@suug.ch,
	Alexandru Copot <alex.mihai.c@gmail.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 941912133025926307c7a65b203fa38403b1063a replaced the macros
NLMSG_NEXT with calls to nlmsg_next which produces this warning:

kernel/audit.c: In function =E2=80=98audit_receive_skb=E2=80=99:
kernel/audit.c:928:3: warning: passing argument 2 of =E2=80=98nlmsg_nex=
t=E2=80=99 makes pointer from integer without a cast
In file included from include/net/rtnetlink.h:5:0,
                 from include/net/neighbour.h:28,
                 from include/net/dst.h:17,
                 from include/net/sock.h:68,
                 from kernel/audit.c:55:
include/net/netlink.h:359:1: note: expected =E2=80=98int *=E2=80=99 but=
 argument is of type =E2=80=98int=E2=80=99

=46ix this by sending the intended pointer.

Signed-off-by: Alexandru Copot <alex.mihai.c@gmail.com>
---
 kernel/audit.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/audit.c b/kernel/audit.c
index 4dbb047..488f85f 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -925,7 +925,7 @@ static void audit_receive_skb(struct sk_buff *skb)
 		if (err || (nlh->nlmsg_flags & NLM_F_ACK))
 			netlink_ack(skb, nlh, err);
=20
-		nlh =3D nlmsg_next(nlh, len);
+		nlh =3D nlmsg_next(nlh, &len);
 	}
 }
=20
--=20
1.8.2
