From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: [PATCH] net/core/sock.c: quiet sparse noise
Date: Thu, 14 Jan 2010 17:21:45 -0700
Message-ID: <201001141721.45305.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Linux Kernel <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757878Ab0AOAVn@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

net/core/sock.c: quiet sparse noise

In sock_getsockopt the symbol 'lv' is declared as an
unsigned int type, probably due to sizeof returning a
size_t which is really an unsigned int.

This produces a sparse warning for SO_PEERNAME due to
the sock->ops->getname() call:

warning: incorrect type in argument 3 (different signedness)
   expected int *sockaddr_len
   got unsigned int *<noident>

Quiet the warning my changing the type of 'lv' to an int.

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: David S. Miller <davem@davemloft.net>

---

diff --git a/net/core/sock.c b/net/core/sock.c
index e1f6f22..10b1d32 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -741,7 +741,7 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		struct timeval tm;
 	} v;
 
-	unsigned int lv = sizeof(int);
+	int lv = sizeof(int);
 	int len;
 
 	if (get_user(len, optlen))
