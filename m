From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH] Ensure local assignment bit on tun device MAC addr
Date: Sat, 31 Mar 2007 10:49:12 +1000
Message-ID: <1175302152.12230.414.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:54783 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933211AbXCaAtd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Mar 2007 20:49:33 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This becomes especially important after the tun patch sitting in the -mm
tree is applied, but it works standalone.  Please apply.  (See netdev
posting Message-Id: <200703270550.l2R5o0Mh008378@shell0.pdx.osdl.net>)

==
The effect of this bug was made worse by Brian Braunstein's patch to keep
net_device.dev_addr and tun.dev_addr in sync.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

diff -r fd8c40f4f533 drivers/net/tun.c
--- a/drivers/net/tun.c	Fri Mar 30 17:02:19 2007 +1000
+++ b/drivers/net/tun.c	Sat Mar 31 10:30:47 2007 +1000
@@ -507,9 +507,7 @@ static int tun_set_iff(struct file *file
 		tun->flags = flags;
 		/* Be promiscuous by default to maintain previous behaviour. */
 		tun->if_flags = IFF_PROMISC;
-		/* Generate random Ethernet address. */
-		*(u16 *)tun->dev_addr = htons(0x00FF);
-		get_random_bytes(tun->dev_addr + sizeof(u16), 4);
+		random_ether_addr(tun->dev_addr);
 		memset(tun->chr_filter, 0, sizeof tun->chr_filter);
 
 		tun_net_init(dev);


