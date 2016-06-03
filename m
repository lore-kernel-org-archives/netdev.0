From: Helge Deller <deller@gmx.de>
Subject: [PATCH] soreuseport: add compat case for setsockopt
 SO_ATTACH_REUSEPORT_CBPF
Date: Fri, 3 Jun 2016 19:18:05 +0200
Message-ID: <20160603171805.GA3664@ls3530.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-parisc@vger.kernel.org
To: Craig Gallek <kraig@google.com>,
	Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-parisc-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 538950a ("soreuseport: setsockopt SO_ATTACH_REUSEPORT_[CE]BPF")
missed to add the compat case for the SO_ATTACH_REUSEPORT_CBPF
setsockoption() option.

Since both SO_ATTACH_FILTER and SO_ATTACH_REUSEPORT_CBPF use a struct
sock_fprog let's combine the handling of both.

Signed-off-by: Helge Deller <deller@gmx.de>

diff --git a/net/compat.c b/net/compat.c
index 5cfd26a..7e2aac9 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -309,7 +309,7 @@ void scm_detach_fds_compat(struct msghdr *kmsg, struct scm_cookie *scm)
 	__scm_destroy(scm);
 }
 
-static int do_set_attach_filter(struct socket *sock, int level, int optname,
+static int do_sockopt_fix_sock_fprog(struct socket *sock, int level, int optname,
 				char __user *optval, unsigned int optlen)
 {
 	struct compat_sock_fprog __user *fprog32 = (struct compat_sock_fprog __user *)optval;
@@ -354,8 +354,9 @@ static int do_set_sock_timeout(struct socket *sock, int level,
 static int compat_sock_setsockopt(struct socket *sock, int level, int optname,
 				char __user *optval, unsigned int optlen)
 {
-	if (optname == SO_ATTACH_FILTER)
-		return do_set_attach_filter(sock, level, optname,
+	if (optname == SO_ATTACH_FILTER ||
+	    optname == SO_ATTACH_REUSEPORT_CBPF)
+		return do_sockopt_fix_sock_fprog(sock, level, optname,
 					    optval, optlen);
 	if (optname == SO_RCVTIMEO || optname == SO_SNDTIMEO)
 		return do_set_sock_timeout(sock, level, optname, optval, optlen);
