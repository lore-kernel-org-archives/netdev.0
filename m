From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] [NET] socket.c: zero socket addresses
	before use.
Date: Tue, 20 Sep 2005 11:18:23 -0600
Message-ID: <m1hdcfhd40.fsf_-_@ebiederm.dsl.xmission.com>
References: <m164t8ltrs.fsf_-_@ebiederm.dsl.xmission.com>
	<20050912.141351.50320521.davem@davemloft.net>
	<m1ek7ulyt8.fsf@ebiederm.dsl.xmission.com>
	<20050912.154527.48978091.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: openib-general@openib.org, netdev@vger.kernel.org
Return-path: <openib-general-bounces@openib.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050912.154527.48978091.davem@davemloft.net> (David S.
	Miller's message of "Mon, 12 Sep 2005 15:45:27 -0700 (PDT)")
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org


Dave I don't know if this is part of what you want but
zeroing the socket address buffer before use seem to be implied
by what you were asking for.   So here is an additional patch
to implement that.

This is a paranoid precaution to guard against accidental
information leaks to user space or other consumers/producers
may fail to properly fail to set or read the hardware
address length. af_packet over ethernet has had at least
has one small but in this respect.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>


---

 net/socket.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

957ae0f034aa1482e42da948b2d87ae6fc13366e
diff --git a/net/socket.c b/net/socket.c
--- a/net/socket.c
+++ b/net/socket.c
@@ -1285,6 +1285,7 @@ asmlinkage long sys_bind(int fd, struct 
 	char address[MAX_SOCK_ADDR];
 	int err;
 
+	memset(address, 0, sizeof(address));
 	if((sock = sockfd_lookup(fd,&err))!=NULL)
 	{
 		if((err=move_addr_to_kernel(umyaddr,addrlen,address))>=0) {
@@ -1349,6 +1350,7 @@ asmlinkage long sys_accept(int fd, struc
 	int err, len;
 	char address[MAX_SOCK_ADDR];
 
+	memset(address, 0, sizeof(address));
 	sock = sockfd_lookup(fd, &err);
 	if (!sock)
 		goto out;
@@ -1419,6 +1421,7 @@ asmlinkage long sys_connect(int fd, stru
 	char address[MAX_SOCK_ADDR];
 	int err;
 
+	memset(address, 0, sizeof(address));
 	sock = sockfd_lookup(fd, &err);
 	if (!sock)
 		goto out;
@@ -1449,6 +1452,7 @@ asmlinkage long sys_getsockname(int fd, 
 	char address[MAX_SOCK_ADDR];
 	int len, err;
 	
+	memset(address, 0, sizeof(address));
 	sock = sockfd_lookup(fd, &err);
 	if (!sock)
 		goto out;
@@ -1479,6 +1483,7 @@ asmlinkage long sys_getpeername(int fd, 
 	char address[MAX_SOCK_ADDR];
 	int len, err;
 
+	memset(address, 0, sizeof(address));
 	if ((sock = sockfd_lookup(fd, &err))!=NULL)
 	{
 		err = security_socket_getpeername(sock);
@@ -1510,6 +1515,7 @@ asmlinkage long sys_sendto(int fd, void 
 	struct msghdr msg;
 	struct iovec iov;
 	
+	memset(address, 0, sizeof(address));
 	sock = sockfd_lookup(fd, &err);
 	if (!sock)
 		goto out;
@@ -1564,6 +1570,7 @@ asmlinkage long sys_recvfrom(int fd, voi
 	char address[MAX_SOCK_ADDR];
 	int err,err2;
 
+	memset(address, 0, sizeof(address));
 	sock = sockfd_lookup(fd, &err);
 	if (!sock)
 		goto out;
@@ -1705,6 +1712,7 @@ asmlinkage long sys_sendmsg(int fd, stru
 	struct msghdr msg_sys;
 	int err, ctl_len, iov_size, total_len;
 	
+	memset(address, 0, sizeof(address));
 	err = -EFAULT;
 	if (MSG_CMSG_COMPAT & flags) {
 		if (get_compat_msghdr(&msg_sys, msg_compat))
@@ -1806,6 +1814,7 @@ asmlinkage long sys_recvmsg(int fd, stru
 	struct sockaddr __user *uaddr;
 	int __user *uaddr_len;
 	
+	memset(addr, 0, sizeof(addr));
 	if (MSG_CMSG_COMPAT & flags) {
 		if (get_compat_msghdr(&msg_sys, msg_compat))
 			return -EFAULT;
