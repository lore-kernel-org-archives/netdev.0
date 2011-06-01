From: Ben Greear <greearb@candelatech.com>
Subject: patch for ixgbe-3.3.9 (out-of-tree) driver.
Date: Wed, 01 Jun 2011 10:50:25 -0700
Message-ID: <4DE67BE1.3060704@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010309090804020508060303"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:59480 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758108Ab1FARu0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 13:50:26 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id p51HoPD8005192
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 1 Jun 2011 10:50:26 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010309090804020508060303
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Using 'ethtool -t ethX' with 82598 chipset causes
kernel splats because spin-lock wasn't initialized properly.
This can probably cause other problems, but I'm not certain
of that.

I can't tell that anyone actually watches the sourceforge list,
so posting it here...

The reason I'm using the out-of-tree driver is that a customer
reports link bouncing when using the 82598 NIC.  They are stuck
on a .34 kernel at the moment, so maybe it's fixed upstream already.
At any rate, I can't reproduce the problem locally, but the 3.3.9
driver appears to work for them.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


--------------010309090804020508060303
Content-Type: text/plain;
 name="ixgbe-3.3.9.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="ixgbe-3.3.9.patch"

--- ixgbe-3.3.9/src/ixgbe_main.c	2011-04-19 16:06:31.000000000 -0700
+++ ixgbe-3.3.9.ben/src/ixgbe_main.c	2011-06-01 10:31:23.163839562 -0700
@@ -5843,16 +5843,18 @@
 			adapter->flags |= IXGBE_FLAG_SRIOV_CAPABLE;
 		if (hw->device_id == IXGBE_DEV_ID_82599_T3_LOM)
 			adapter->flags2 |= IXGBE_FLAG2_TEMP_SENSOR_CAPABLE;
-#ifdef NETIF_F_NTUPLE
-		/* n-tuple support exists, always init our spinlock */
-		spin_lock_init(&adapter->fdir_perfect_lock);
-#endif /* NETIF_F_NTUPLE */
 		adapter->max_msix_q_vectors = IXGBE_MAX_MSIX_Q_VECTORS_82599;
 		break;
 	default:
 		break;
 	}
-	/* Default DCB settings, if applicable */
+
+#ifdef NETIF_F_NTUPLE
+        /* n-tuple support exists, always init our spinlock */
+        spin_lock_init(&adapter->fdir_perfect_lock);
+#endif /* NETIF_F_NTUPLE */
+
+        /* Default DCB settings, if applicable */
 	adapter->ring_feature[RING_F_DCB].indices = 8;
 
 	if (adapter->flags & IXGBE_FLAG_DCB_CAPABLE) {

--------------010309090804020508060303--
