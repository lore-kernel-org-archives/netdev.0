From: Peter Buckingham <peter@pantasys.com>
Subject: [PATCH 2.6] IPCONFIG fix and cleanup
Date: Wed, 08 Sep 2004 17:43:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <413FA726.7070006@pantasys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi David,

The previous fix to DHCPACK missed declaring an iterator variable. based 
on some comments I modified the patch to look like the below. This will 
fix the promisicuous DHCPACK problem.

thanks,

peter

Signed-off-by: Peter Buckingham <peter@pantasys.com>

--- linus-2.6/net/ipv4/ipconfig.c	2004-09-08 17:35:56.000000000 -0700
+++ local_linux/net/ipv4/ipconfig.c	2004-09-07 17:16:55.000000000 -0700
@@ -966,9 +966,7 @@ static int __init ic_bootp_recv(struct s
  				break;

  			case DHCPACK:
-				for (i = 0; (dev->dev_addr[i] == b->hw_addr[i])
-						&& (i < dev->addr_len); i++);
-				if (i < dev->addr_len)
+				if (memcmp(dev->dev_addr, b->hw_addr, dev->addr_len) != 0)
  					goto drop_unlock;

  				/* Yeah! */
