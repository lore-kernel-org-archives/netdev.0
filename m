From: Peter Buckingham <peter@pantasys.com>
Subject: [PATCH 2.6] ipconfig accepts any DHCPACK
Date: Tue, 07 Sep 2004 14:46:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <413E2C26.5040108@pantasys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi David,

I was playing around with using ipconfig to initialise a bunch of 
systems and it turns out that the ipconfig code doesn't check to see 
whether the ACK is for it or another system. I've just added a simple 
check to compare the hardware address of the device to the one in the 
packet.

peter

Signed-off-by: Peter Buckingham <peter@pantasys.com>

--- linus-2.6/net/ipv4/ipconfig.c	2004-09-02 14:53:54.000000000 -0700
+++ local_linux/net/ipv4/ipconfig.c	2004-09-02 14:57:49.000000000 -0700
@@ -966,6 +966,12 @@ static int __init ic_bootp_recv(struct s
  				break;

  			case DHCPACK:
+				for (i = 0; (dev->dev_addr[i] == b->hw_addr[i])
+						&& (i < 16); i++);
+				if (i < 16)
+					goto drop_unlock;
+
  				/* Yeah! */
  				break;
