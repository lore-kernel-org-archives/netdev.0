From: akpm@osdl.org
Subject: [patch 10/13] net/socket.c::sys_bind() cleanup.
Date: Sun, 21 Nov 2004 22:43:56 -0800
Message-ID: <200411220644.iAM6i8900672@mail.osdl.org>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org,
        lcapitulino@conectiva.com.br
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: "Luiz Fernando N. Capitulino" <lcapitulino@conectiva.com.br>

net/socket.c::sys_bind() is a bit complex function, the patch below makes
it more clear.

Signed-off-by: Luiz Capitulino <lcapitulino@conectiva.com.br>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/net/socket.c |   29 +++++++++++++++++------------
 1 files changed, 17 insertions(+), 12 deletions(-)

diff -puN net/socket.c~net-socketcsys_bind-cleanup net/socket.c
--- 25/net/socket.c~net-socketcsys_bind-cleanup	2004-11-21 22:42:53.618530984 -0800
+++ 25-akpm/net/socket.c	2004-11-21 22:43:00.586471696 -0800
@@ -1286,18 +1286,23 @@ asmlinkage long sys_bind(int fd, struct 
 	char address[MAX_SOCK_ADDR];
 	int err;
 
-	if((sock = sockfd_lookup(fd,&err))!=NULL)
-	{
-		if((err=move_addr_to_kernel(umyaddr,addrlen,address))>=0) {
-			err = security_socket_bind(sock, (struct sockaddr *)address, addrlen);
-			if (err) {
-				sockfd_put(sock);
-				return err;
-			}
-			err = sock->ops->bind(sock, (struct sockaddr *)address, addrlen);
-		}
-		sockfd_put(sock);
-	}			
+	sock = sockfd_lookup(fd, &err);
+	if (!sock)
+		goto out;
+
+	err = move_addr_to_kernel(umyaddr, addrlen, address);
+	if (err)
+		goto out_put;
+
+	err = security_socket_bind(sock, (struct sockaddr *)address, addrlen);
+	if (err)
+		goto out_put;
+
+	err = sock->ops->bind(sock, (struct sockaddr *)address, addrlen);
+
+ out_put:
+	sockfd_put(sock);
+ out:
 	return err;
 }
 
_
