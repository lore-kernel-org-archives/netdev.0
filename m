From: Tadeusz Struk <tadeusz.struk@intel.com>
Subject: [PATCH] net: fix uninitialized variable issue
Date: Tue, 15 Dec 2015 10:46:17 -0800
Message-ID: <20151215184617.11620.23369.stgit@tstruk-mobl1>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: tadeusz.struk@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	freude@linux.vnet.ibm.com, viro@zeniv.linux.org.uk,
	linux-crypto@vger.kernel.org
To: herbert@gondor.apana.org.au, davem@davemloft.net
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

msg_iocb needs to be initialized on the recv/recvfrom path.
Otherwise afalg will wrongly interpret it as an async call.

Cc: stable@vger.kernel.org
Reported-by: Harald Freudenberger <freude@linux.vnet.ibm.com>
Signed-off-by: Tadeusz Struk <tadeusz.struk@intel.com>
---
 net/socket.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/socket.c b/net/socket.c
index dd2c247..80ca820 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1702,6 +1702,7 @@ SYSCALL_DEFINE6(recvfrom, int, fd, void __user *, ubuf, size_t, size,
 	msg.msg_name = addr ? (struct sockaddr *)&address : NULL;
 	/* We assume all kernel code knows the size of sockaddr_storage */
 	msg.msg_namelen = 0;
+	msg.msg_iocb = NULL;
 	if (sock->file->f_flags & O_NONBLOCK)
 		flags |= MSG_DONTWAIT;
 	err = sock_recvmsg(sock, &msg, iov_iter_count(&msg.msg_iter), flags);
