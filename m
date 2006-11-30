From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: re: [RFC] [PATCH V2 0/3] bonding support for operation over IPoIB
 - example config script
Date: Thu, 30 Nov 2006 13:00:46 +0200 (IST)
Message-ID: <Pine.LNX.4.64.0611301258410.26156@zuben>
References: <Pine.LNX.4.64.0611301256130.26156@zuben>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: openib-general@openib.org, Roland Dreier <rdreier@cisco.com>,
	Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from taurus.voltaire.com ([193.47.165.240]:53979 "EHLO
	taurus.voltaire.com") by vger.kernel.org with ESMTP id S935686AbWK3LAs
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 06:00:48 -0500
To: netdev@vger.kernel.org
In-Reply-To: <Pine.LNX.4.64.0611301256130.26156@zuben>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Below is an example script i was using to configure bonding in my testing

Or.

--- /dev/null	2006-10-30 17:30:04.465997856 +0200
+++ bond_init_sysfs.bash	2006-11-30 12:51:05.109565889 +0200
@@ -0,0 +1,25 @@
+#!/bin/bash
+
+BOND_IP=192.168.10.118
+BOND_NETMASK=255.255.255.0
+
+SLAVE_A=ib0
+SLAVE_B=ib1
+
+modprobe bonding
+
+echo active-backup > /sys/class/net/bond0/bonding/mode
+echo 100           > /sys/class/net/bond0/bonding/miimon
+
+modprobe ib_ipoib
+
+## this is some debug info that can enable seeing below the scenes...
+## to learn more see Documentation/infiniband/ipoib.txt
+
+#echo 1 > /sys/module/ib_ipoib/parameters/mcast_debug_level
+#echo 1 > /sys/module/ib_ipoib/parameters/debug_level
+
+echo +$SLAVE_A > /sys/class/net/bond0/bonding/slaves
+echo +$SLAVE_B > /sys/class/net/bond0/bonding/slaves
+
+ifconfig bond0 $BOND_IP netmask $BOND_NETMASK up
