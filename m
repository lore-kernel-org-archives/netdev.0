From: Matt Domsch <Matt_Domsch@dell.com>
Subject: [PATCH 2.6] dev.c: clear SIOCGIFHWADDR buffer if !dev->addr_len
Date: Fri, 29 Oct 2004 16:51:34 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029215134.GA15414@lists.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

If dev->dev_addr is zero, then the memcpy() never takes place, and the
same data that was in the caller's buffer is still in the caller's
buffer on successful return.  The caller can't know that the data in
its buffer isn't the right answer.  So, if dev->dev_dev_addr == 0,
clear the buffer before returning success.

Thanks,
Matt

-- 
Matt Domsch
Sr. Software Engineer, Lead Engineer
Dell Linux Solutions linux.dell.com & www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com

===== linux-2.6/net/core/dev.c 1.169 vs edited =====
--- 1.169/net/core/dev.c	2004-10-26 11:09:33 -05:00
+++ edited/linux-2.6/net/core/dev.c	2004-10-29 16:39:33 -05:00
@@ -2375,8 +2375,11 @@
 			return dev_set_mtu(dev, ifr->ifr_mtu);
 
 		case SIOCGIFHWADDR:
-			memcpy(ifr->ifr_hwaddr.sa_data, dev->dev_addr,
-			       min(sizeof ifr->ifr_hwaddr.sa_data, (size_t) dev->addr_len));
+			if (!dev->addr_len)
+				memset(ifr->ifr_hwaddr.sa_data, 0, sizeof ifr->ifr_hwaddr.sa_data);
+			else
+				memcpy(ifr->ifr_hwaddr.sa_data, dev->dev_addr,
+				       min(sizeof ifr->ifr_hwaddr.sa_data, (size_t) dev->addr_len));
 			ifr->ifr_hwaddr.sa_family = dev->type;
 			return 0;
 
