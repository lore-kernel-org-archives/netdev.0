From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] ipv6: sctp: implement sctp_v6_destroy_sock()
Date: Tue, 01 Dec 2015 07:20:07 -0800
Message-ID: <1448983207.25582.29.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CACT4Y+bv56b+opCd=5SHmN47MAHEFyZA18kSsu-Fa+XODj20PA@mail.gmail.com>
	 <1448977016.25582.18.camel@edumazet-glaptop2.roam.corp.google.com>
	 <565DA9BE.3060006@iogearbox.net>
	 <1448979404.25582.23.camel@edumazet-glaptop2.roam.corp.google.com>
	 <565DAD8D.9020800@iogearbox.net>
	 <1448980723.25582.24.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	linux-sctp@vger.kernel.org, syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448980723.25582.24.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <edumazet@google.com>

Dmitry Vyukov reported a memory leak using IPV6 SCTP sockets.

We need to call inet6_destroy_sock() to properly release
inet6 specific fields.

Reported-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sctp/socket.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 897c01c029ca..9d0b9bae9052 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -7375,6 +7375,13 @@ struct proto sctp_prot = {
 
 #if IS_ENABLED(CONFIG_IPV6)
 
+#include <net/transp_v6.h>
+static void sctp_v6_destroy_sock(struct sock *sk)
+{
+	sctp_destroy_sock(sk);
+	inet6_destroy_sock(sk);
+}
+
 struct proto sctpv6_prot = {
 	.name		= "SCTPv6",
 	.owner		= THIS_MODULE,
@@ -7384,7 +7391,7 @@ struct proto sctpv6_prot = {
 	.accept		= sctp_accept,
 	.ioctl		= sctp_ioctl,
 	.init		= sctp_init_sock,
-	.destroy	= sctp_destroy_sock,
+	.destroy	= sctp_v6_destroy_sock,
 	.shutdown	= sctp_shutdown,
 	.setsockopt	= sctp_setsockopt,
 	.getsockopt	= sctp_getsockopt,
