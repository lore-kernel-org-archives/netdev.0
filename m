From: Patrick McHardy <kaber@trash.net>
Subject: [UML]: uml-net: don't set IFF_ALLMULTI in set_multicast_list
Date: Wed, 26 Mar 2008 06:46:25 +0100
Message-ID: <47E9E331.1010105@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010603000107020409050200"
Cc: user-mode-linux-devel@lists.sourceforge.net,
	Linux Netdev List <netdev@vger.kernel.org>
To: jdike@addtoit.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:13360 "EHLO
	viefep14-int.chello.at" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751537AbYCZFqa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 01:46:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010603000107020409050200
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------010603000107020409050200
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit 00237037726efc587d55d65d6fd5357106ae7071
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Mar 26 06:41:22 2008 +0100

    [UML]: uml-net: don't set IFF_ALLMULTI in set_multicast_list
    
    IFF_ALLMULTI is an indication from the network stack to the driver
    to disable multicast filters, drivers should never set it directly.
    
    Since the UML networking device doesn't have any filtering capabilites,
    it doesn't the set_multicast_list function at all, it is kept so userspace
    can still issue SIOCADDMULTI/SIOCDELMULTI ioctls however.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/arch/um/drivers/net_kern.c b/arch/um/drivers/net_kern.c
index 1e8f41a..1d43bdf 100644
--- a/arch/um/drivers/net_kern.c
+++ b/arch/um/drivers/net_kern.c
@@ -256,11 +256,7 @@ static struct net_device_stats *uml_net_get_stats(struct net_device *dev)
 
 static void uml_net_set_multicast_list(struct net_device *dev)
 {
-	if (dev->flags & IFF_PROMISC)
-		return;
-	else if (dev->mc_count)
-		dev->flags |= IFF_ALLMULTI;
-	else dev->flags &= ~IFF_ALLMULTI;
+	return;
 }
 
 static void uml_net_tx_timeout(struct net_device *dev)

--------------010603000107020409050200--
