From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH 2.4 1/13] e1000: ITR does not default correctly
Date: Thu, 6 Jan 2005 17:04:14 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0501061455300.7330-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
diff -up net-drivers-2.4/drivers/net/e1000/e1000_param.c net-drivers-2.4/drivers/net/e1000.new/e1000_param.c
--- net-drivers-2.4/drivers/net/e1000/e1000_param.c	2004-12-06 08:43:11.635381920 -0800
+++ net-drivers-2.4/drivers/net/e1000.new/e1000_param.c	2004-12-06 08:43:12.622231896 -0800
@@ -447,9 +447,6 @@ e1000_check_options(struct e1000_adapter
 
 			adapter->itr = InterruptThrottleRate[bd];
 			switch(adapter->itr) {
-			case -1:
-				adapter->itr = 1;
-				break;
 			case 0:
 				DPRINTK(PROBE, INFO, "%s turned off\n", 
 					opt.name);
@@ -458,6 +455,7 @@ e1000_check_options(struct e1000_adapter
 				DPRINTK(PROBE, INFO, "%s set to dynamic mode\n", 
 					opt.name);
 				break;
+			case -1:
 			default:
 				e1000_validate_option(&adapter->itr, &opt, 
 					adapter);
