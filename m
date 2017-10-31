From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] net: recvmsg: Unconditionally zero struct sockaddr_storage
Date: Tue, 31 Oct 2017 09:14:45 -0700
Message-ID: <20171031161445.GA140874@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Potapenko <glider@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, security@kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some protocols do not correctly wipe the contents of the on-stack
struct sockaddr_storage sent down into recvmsg() (e.g. SCTP), and leak
kernel stack contents to userspace. This wipes it unconditionally before
per-protocol handlers run.

Note that leaks like this are mitigated by building with
CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF_ALL=y

Reported-by: Alexander Potapenko <glider@google.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 net/socket.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/socket.c b/net/socket.c
index c729625eb5d3..34183f4fbdf8 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2188,6 +2188,7 @@ static int ___sys_recvmsg(struct socket *sock, struct user_msghdr __user *msg,
 	struct sockaddr __user *uaddr;
 	int __user *uaddr_len = COMPAT_NAMELEN(msg);
 
+	memset(&addr, 0, sizeof(addr));
 	msg_sys->msg_name = &addr;
 
 	if (MSG_CMSG_COMPAT & flags)
-- 
2.7.4


-- 
Kees Cook
Pixel Security
