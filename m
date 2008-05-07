From: Patrick McHardy <kaber@trash.net>
Subject: [MACVLAN]: Fix memleak on device removal/crash on module removal
Date: Wed, 07 May 2008 09:43:40 +0200
Message-ID: <48215DAC.1070704@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060609020407020501080301"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55044 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760737AbYEGHoR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 03:44:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060609020407020501080301
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------060609020407020501080301
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit 2fe876e51d1f053b55d8d50c3733b136b6add016
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed May 7 09:43:05 2008 +0200

    [MACVLAN]: Fix memleak on device removal/crash on module removal
    
    As noticed by Ben Greear, macvlan crashes the kernel when unloading the
    module. The reason is that it tries to clean up the macvlan_port pointer
    on the macvlan device itself instead of the underlying device. A non-NULL
    pointer is taken as indication that the macvlan_handle_frame_hook is
    valid, when receiving the next packet on the underlying device it tries
    to call the NULL hook and crashes.
    
    Clean up the macvlan_port on the correct device to fix this.
    
    Signed-off-by; Patrick McHardy <kaber@trash.net>

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 2056cfc..c36a03a 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -450,7 +450,7 @@ static void macvlan_dellink(struct net_device *dev)
 	unregister_netdevice(dev);
 
 	if (list_empty(&port->vlans))
-		macvlan_port_destroy(dev);
+		macvlan_port_destroy(port->dev);
 }
 
 static struct rtnl_link_ops macvlan_link_ops __read_mostly = {

--------------060609020407020501080301--
