From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [Patch 1/5 2.4] e1000: fix set_pauseparam for fiber serdes link
Date: Fri, 15 Oct 2004 06:50:56 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410150526050.31227-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up linux-2.4/drivers/net/e1000/e1000_ethtool.c linux-2.4/drivers/net/e1000.new/e1000_ethtool.c
--- linux-2.4/drivers/net/e1000/e1000_ethtool.c	2004-10-07 09:11:14.000000000 -0700
+++ linux-2.4/drivers/net/e1000.new/e1000_ethtool.c	2004-10-07 09:11:17.000000000 -0700
@@ -249,7 +249,8 @@ e1000_set_pauseparam(struct net_device *
 			e1000_reset(adapter);
 	}
 	else
-		return e1000_force_mac_fc(hw);
+		return ((hw->media_type == e1000_media_type_fiber) ?
+			e1000_setup_link(hw) : e1000_force_mac_fc(hw));
 	
 	return 0;
 }
