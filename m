From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH 2.6 1/14] e1000: ITR does not default correctly on 2.6.x
 kernels
Date: Thu, 6 Jan 2005 17:20:54 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0501061521200.7330-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
diff -up net-drivers-2.6/drivers/net/e1000/e1000_param.c net-drivers-2.6/drivers/net/e1000.new/e1000_param.c
--- net-drivers-2.6/drivers/net/e1000/e1000_param.c	2004-12-03 07:24:37.091623032 -0800
+++ net-drivers-2.6/drivers/net/e1000.new/e1000_param.c	2004-12-03 07:24:38.662384240 -0800
@@ -470,9 +470,6 @@ e1000_check_options(struct e1000_adapter
 		if (num_InterruptThrottleRate > bd) {
 			adapter->itr = InterruptThrottleRate[bd];
 			switch(adapter->itr) {
-			case -1:
-				adapter->itr = 1;
-				break;
 			case 0:
 				DPRINTK(PROBE, INFO, "%s turned off\n", 
 					opt.name);
@@ -481,13 +478,14 @@ e1000_check_options(struct e1000_adapter
 				DPRINTK(PROBE, INFO, "%s set to dynamic mode\n", 
 					opt.name);
 				break;
+			case -1:
 			default:
 				e1000_validate_option(&adapter->itr, &opt, 
 					adapter);
 				break;
 			}
 		} else {
-			adapter->itr = 1;
+			adapter->itr = opt.def;
 		}
 	}
 
Only in net-drivers-2.6/drivers/net/e1000.new: kcompat_ethtool.c
