From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.70] e100 report link speed via if_port
Date: Thu, 29 May 2003 10:41:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030529104138.751a1f54.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>,
   Scott Feldman
 <scott.feldman@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The e100 driver knows the link speed, but it is not visible through sysfs.
Small patch to update the net_device if_port when speed is detected;
this can then be read through /sys/class/net/eth0/if_port.

--- linux-2.5-incr/drivers/net/e100/e100_main.c	2003-05-29 09:52:35.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/e100/e100_main.c	2003-05-29 08:56:47.000000000 -0700
@@ -1720,12 +1720,22 @@
 			       (bdp->cur_dplx_mode == HALF_DUPLEX) ?
 			       "Half" : "Full");
 
+			if (bdp->cur_line_speed == 10)
+				dev->if_port = IF_PORT_10BASET;
+			else if(bdp->cur_line_speed == 100) {
+				if (bdp->cur_dplx_mode == HALF_DUPLEX) 
+					dev->if_port = 	IF_PORT_100BASETX;
+				else
+					dev->if_port = IF_PORT_100BASEFX;
+			}
+
 			e100_config_fc(bdp);
 			e100_config(bdp);  
 
 		} else {
 			printk(KERN_ERR "e100: %s NIC Link is Down\n",
 			       bdp->device->name);
+			dev->if_port = IF_PORT_UNKNOWN;
 		}
 	}
 
