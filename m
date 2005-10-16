From: Yan Zheng <yanzheng@21cn.com>
Subject: [PATCH]The second param of addrconf_ifdown() in function addrconf_notify()
 for event NETDEV_CHANGEMTU.
Date: Sun, 16 Oct 2005 23:25:29 +0800
Message-ID: <435270E9.10005@21cn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751324AbVJPPYZ@vger.kernel.org>
To: netdev@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi. 
I think the second parameter of addrconf_ifdown() should be 0 for event NETDEV_CHANGEMTU.




Signed-off-by: Yan Zheng  <yanzheng@21cn.com>

Index: net/ipv6/addrconf.c
===================================================================
--- linux-2.6.14-rc4-git2/net/ipv6/addrconf.c	2005-10-14 18:28:01.000000000 +0800
+++ linux/net/ipv6/addrconf.c	2005-10-16 23:04:40.000000000 +0800
@@ -2018,7 +2018,7 @@
 			   stop IPv6 on this interface.
 			 */
 			if (dev->mtu < IPV6_MIN_MTU)
-				addrconf_ifdown(dev, event != NETDEV_DOWN);
+				addrconf_ifdown(dev, 0);
 		}
 		break;
 
@@ -2036,7 +2036,7 @@
 		/*
 		 *	Remove all addresses from this interface.
 		 */
-		addrconf_ifdown(dev, event != NETDEV_DOWN);
+		addrconf_ifdown(dev, event == NETDEV_UNREGISTER);
 		break;
 	case NETDEV_CHANGE:
 		break;
