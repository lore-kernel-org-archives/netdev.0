From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/5] socket: suppress sparse warnings
Date: Wed, 23 Feb 2011 11:06:48 -0800
Message-ID: <20110223190700.877761282@vyatta.com>
References: <20110223190647.482444598@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:44644 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752485Ab1BWTxC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Feb 2011 14:53:02 -0500
Content-Disposition: inline; filename=socket-sparse
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use __force to quiet sparse warnings for cases where the code
is simulating user space pointers.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/socket.c	2011-02-23 08:26:51.905069267 -0800
+++ b/net/socket.c	2011-02-23 08:26:59.005160474 -0800
@@ -2648,7 +2648,8 @@ static int bond_ioctl(struct net *net, u
 
 		old_fs = get_fs();
 		set_fs(KERNEL_DS);
-		err = dev_ioctl(net, cmd, &kifr);
+		err = dev_ioctl(net, cmd,
+				(struct ifreq __user __force *) &kifr);
 		set_fs(old_fs);
 
 		return err;
@@ -2757,7 +2758,7 @@ static int compat_sioc_ifmap(struct net
 
 	old_fs = get_fs();
 	set_fs(KERNEL_DS);
-	err = dev_ioctl(net, cmd, (void __user *)&ifr);
+	err = dev_ioctl(net, cmd, (void  __user __force *)&ifr);
 	set_fs(old_fs);
 
 	if (cmd == SIOCGIFMAP && !err) {
@@ -2862,7 +2863,8 @@ static int routing_ioctl(struct net *net
 		ret |= __get_user(rtdev, &(ur4->rt_dev));
 		if (rtdev) {
 			ret |= copy_from_user(devname, compat_ptr(rtdev), 15);
-			r4.rt_dev = devname; devname[15] = 0;
+			r4.rt_dev = (char __user __force *)devname;
+			devname[15] = 0;
 		} else
 			r4.rt_dev = NULL;
 


