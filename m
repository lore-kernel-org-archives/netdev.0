From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] [sparse] ip_rt_ioctl argument is user pointer
Date: Tue, 22 Jun 2004 16:00:22 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040622160022.75db69bb@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The function ip_rt_ioctl expects a pointer to a user route structure, so define
it that way and cast as appropriate.

diff -Nru a/include/net/route.h b/include/net/route.h
--- a/include/net/route.h	2004-06-22 15:57:28 -07:00
+++ b/include/net/route.h	2004-06-22 15:57:28 -07:00
@@ -129,7 +129,7 @@
 
 extern unsigned		inet_addr_type(u32 addr);
 extern void		ip_rt_multicast_event(struct in_device *);
-extern int		ip_rt_ioctl(unsigned int cmd, void *arg);
+extern int		ip_rt_ioctl(unsigned int cmd, void __user *arg);
 extern void		ip_rt_get_source(u8 *src, struct rtable *rt);
 extern int		ip_rt_dump(struct sk_buff *skb,  struct netlink_callback *cb);
 
diff -Nru a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
--- a/net/ipv4/af_inet.c	2004-06-22 15:57:28 -07:00
+++ b/net/ipv4/af_inet.c	2004-06-22 15:57:28 -07:00
@@ -848,7 +848,7 @@
 		case SIOCADDRT:
 		case SIOCDELRT:
 		case SIOCRTMSG:
-			err = ip_rt_ioctl(cmd, (void *)arg);
+			err = ip_rt_ioctl(cmd, (void __user *)arg);
 			break;
 		case SIOCDARP:
 		case SIOCGARP:
diff -Nru a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
--- a/net/ipv4/fib_frontend.c	2004-06-22 15:57:28 -07:00
+++ b/net/ipv4/fib_frontend.c	2004-06-22 15:57:28 -07:00
@@ -235,7 +235,7 @@
  *	Handle IP routing ioctl calls. These are used to manipulate the routing tables
  */
  
-int ip_rt_ioctl(unsigned int cmd, void *arg)
+int ip_rt_ioctl(unsigned int cmd, void __user *arg)
 {
 	int err;
 	struct kern_rta rta;
diff -Nru a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
--- a/net/ipv4/ipconfig.c	2004-06-22 15:57:28 -07:00
+++ b/net/ipv4/ipconfig.c	2004-06-22 15:57:28 -07:00
@@ -272,7 +272,7 @@
 
 	mm_segment_t oldfs = get_fs();
 	set_fs(get_ds());
-	res = devinet_ioctl(cmd, arg);
+	res = devinet_ioctl(cmd, (struct ifreq __user *) arg);
 	set_fs(oldfs);
 	return res;
 }
@@ -283,7 +283,7 @@
 
 	mm_segment_t oldfs = get_fs();
 	set_fs(get_ds());
-	res = ip_rt_ioctl(cmd, arg);
+	res = ip_rt_ioctl(cmd, (void __user *) arg);
 	set_fs(oldfs);
 	return res;
 }
