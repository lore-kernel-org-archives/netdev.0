From: Zhao Hongjiang <zhaohongjiang37@gmail.com>
Subject: [PATCH] net: change return values from -EACCES to -EPERM
Date: Fri, 21 Sep 2012 16:37:25 +0800
Message-ID: <505C2745.4080704@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, serge.hallyn@canonical.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:41251 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756447Ab2IUIhh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 04:37:37 -0400
Received: by eaac11 with SMTP id c11so978529eaa.19
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2012 01:37:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhao Hongjiang <zhaohongjiang@huawei.com>

Change return value from -EACCES to -EPERM when the permission check fails.

Signed-off-by: Zhao Hongjiang <zhaohongjiang@huawei.com>
---
 net/bluetooth/bnep/sock.c |    4 ++--
 net/bluetooth/cmtp/sock.c |    4 ++--
 net/bluetooth/hci_sock.c  |   16 ++++++++--------
 net/bluetooth/hidp/sock.c |    4 ++--
 net/ipv4/devinet.c        |    4 ++--
 net/netrom/af_netrom.c    |    2 +-
 6 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/net/bluetooth/bnep/sock.c b/net/bluetooth/bnep/sock.c
index 5b6cc0b..e7154a5 100644
--- a/net/bluetooth/bnep/sock.c
+++ b/net/bluetooth/bnep/sock.c
@@ -64,7 +64,7 @@ static int bnep_sock_ioctl(struct socket *sock, unsigned int cmd, unsigned long
 	switch (cmd) {
 	case BNEPCONNADD:
 		if (!capable(CAP_NET_ADMIN))
-			return -EACCES;
+			return -EPERM;

 		if (copy_from_user(&ca, argp, sizeof(ca)))
 			return -EFAULT;
@@ -90,7 +90,7 @@ static int bnep_sock_ioctl(struct socket *sock, unsigned int cmd, unsigned long

 	case BNEPCONNDEL:
 		if (!capable(CAP_NET_ADMIN))
-			return -EACCES;
+			return -EPERM;

 		if (copy_from_user(&cd, argp, sizeof(cd)))
 			return -EFAULT;
diff --git a/net/bluetooth/cmtp/sock.c b/net/bluetooth/cmtp/sock.c
index d5cacef..aacb802 100644
--- a/net/bluetooth/cmtp/sock.c
+++ b/net/bluetooth/cmtp/sock.c
@@ -78,7 +78,7 @@ static int cmtp_sock_ioctl(struct socket *sock, unsigned int cmd, unsigned long
 	switch (cmd) {
 	case CMTPCONNADD:
 		if (!capable(CAP_NET_ADMIN))
-			return -EACCES;
+			return -EPERM;

 		if (copy_from_user(&ca, argp, sizeof(ca)))
 			return -EFAULT;
@@ -103,7 +103,7 @@ static int cmtp_sock_ioctl(struct socket *sock, unsigned int cmd, unsigned long

 	case CMTPCONNDEL:
 		if (!capable(CAP_NET_ADMIN))
-			return -EACCES;
+			return -EPERM;

 		if (copy_from_user(&cd, argp, sizeof(cd)))
 			return -EFAULT;
diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
index bb64331..07f0739 100644
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -490,7 +490,7 @@ static int hci_sock_bound_ioctl(struct sock *sk, unsigned int cmd,
 	switch (cmd) {
 	case HCISETRAW:
 		if (!capable(CAP_NET_ADMIN))
-			return -EACCES;
+			return -EPERM;

 		if (test_bit(HCI_QUIRK_RAW_DEVICE, &hdev->quirks))
 			return -EPERM;
@@ -510,12 +510,12 @@ static int hci_sock_bound_ioctl(struct sock *sk, unsigned int cmd,

 	case HCIBLOCKADDR:
 		if (!capable(CAP_NET_ADMIN))
-			return -EACCES;
+			return -EPERM;
 		return hci_sock_blacklist_add(hdev, (void __user *) arg);

 	case HCIUNBLOCKADDR:
 		if (!capable(CAP_NET_ADMIN))
-			return -EACCES;
+			return -EPERM;
 		return hci_sock_blacklist_del(hdev, (void __user *) arg);

 	default:
@@ -546,22 +546,22 @@ static int hci_sock_ioctl(struct socket *sock, unsigned int cmd,

 	case HCIDEVUP:
 		if (!capable(CAP_NET_ADMIN))
-			return -EACCES;
+			return -EPERM;
 		return hci_dev_open(arg);

 	case HCIDEVDOWN:
 		if (!capable(CAP_NET_ADMIN))
-			return -EACCES;
+			return -EPERM;
 		return hci_dev_close(arg);

 	case HCIDEVRESET:
 		if (!capable(CAP_NET_ADMIN))
-			return -EACCES;
+			return -EPERM;
 		return hci_dev_reset(arg);

 	case HCIDEVRESTAT:
 		if (!capable(CAP_NET_ADMIN))
-			return -EACCES;
+			return -EPERM;
 		return hci_dev_reset_stat(arg);

 	case HCISETSCAN:
@@ -573,7 +573,7 @@ static int hci_sock_ioctl(struct socket *sock, unsigned int cmd,
 	case HCISETACLMTU:
 	case HCISETSCOMTU:
 		if (!capable(CAP_NET_ADMIN))
-			return -EACCES;
+			return -EPERM;
 		return hci_dev_cmd(cmd, argp);

 	case HCIINQUIRY:
diff --git a/net/bluetooth/hidp/sock.c b/net/bluetooth/hidp/sock.c
index eca3889..82a829d 100644
--- a/net/bluetooth/hidp/sock.c
+++ b/net/bluetooth/hidp/sock.c
@@ -62,7 +62,7 @@ static int hidp_sock_ioctl(struct socket *sock, unsigned int cmd, unsigned long
 	switch (cmd) {
 	case HIDPCONNADD:
 		if (!capable(CAP_NET_ADMIN))
-			return -EACCES;
+			return -EPERM;

 		if (copy_from_user(&ca, argp, sizeof(ca)))
 			return -EFAULT;
@@ -97,7 +97,7 @@ static int hidp_sock_ioctl(struct socket *sock, unsigned int cmd, unsigned long

 	case HIDPCONNDEL:
 		if (!capable(CAP_NET_ADMIN))
-			return -EACCES;
+			return -EPERM;

 		if (copy_from_user(&cd, argp, sizeof(cd)))
 			return -EFAULT;
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 7b00556..2a6abc1 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -722,7 +722,7 @@ int devinet_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 		break;

 	case SIOCSIFFLAGS:
-		ret = -EACCES;
+		ret = -EPERM;
 		if (!capable(CAP_NET_ADMIN))
 			goto out;
 		break;
@@ -730,7 +730,7 @@ int devinet_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 	case SIOCSIFBRDADDR:	/* Set the broadcast address */
 	case SIOCSIFDSTADDR:	/* Set the destination address */
 	case SIOCSIFNETMASK: 	/* Set the netmask for the interface */
-		ret = -EACCES;
+		ret = -EPERM;
 		if (!capable(CAP_NET_ADMIN))
 			goto out;
 		ret = -EINVAL;
diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index 1b9024e..7261eb8 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -601,7 +601,7 @@ static int nr_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		if (!capable(CAP_NET_BIND_SERVICE)) {
 			dev_put(dev);
 			release_sock(sk);
-			return -EACCES;
+			return -EPERM;
 		}
 		nr->user_addr   = addr->fsa_digipeater[0];
 		nr->source_addr = addr->fsa_ax25.sax25_call;
-- 1.7.1
