From: Octavian Purdila <tavi@cs.pub.ro>
Subject: netlink_proto_init and sock_init
Date: Thu, 27 Dec 2007 14:48:56 +0200
Message-ID: <200712271448.57008.tavi@cs.pub.ro>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from prof.cs.pub.ro ([141.85.37.3]:45492 "EHLO profus.cs.pub.ro"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751704AbXL0M4i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Dec 2007 07:56:38 -0500
Received: from localhost (localhost [127.0.0.1])
	by profus.cs.pub.ro (Postfix) with ESMTP id DC53B156C8F
	for <netdev@vger.kernel.org>; Thu, 27 Dec 2007 15:48:26 +0200 (EET)
Received: from profus.cs.pub.ro ([127.0.0.1])
	by localhost (profus.cs.pub.ro [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 22071-06 for <netdev@vger.kernel.org>;
	Thu, 27 Dec 2007 15:48:18 +0200 (EET)
Received: from ixro-opurdila-lap.local (unknown [79.114.157.14])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	by profus.cs.pub.ro (Postfix) with ESMTP id D7549156C63
	for <netdev@vger.kernel.org>; Thu, 27 Dec 2007 15:48:18 +0200 (EET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

I've noticed that with some exotic build setups (e.g. mingw) 
netlink_proto_init is called before sock_init and subsequently sock_alloc 
runs into a NULL sock_mnt. The following patch seems to fix the problem, but 
I'm not sure if this is the right thing to do, as there are no _initcall_sync 
calls in the kernel yet. 

Thanks,
tavi

PS: please keep me on CC as I am not subscribed to the list.

Author: Octavian Purdila <tavi@cs.pub.ro>
Date:   Thu Dec 27 14:25:31 2007 +0200

    sock_init needs to be called before netlink_proto_init, but both
    sock_init and netlink_proto_init share the same init level
    (core). Move netlink_proto_init to sync core level.

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 1f15821..f69c126 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1845,7 +1845,7 @@ panic:
        panic("netlink_init: Cannot allocate nl_table\n");
 }
 
-core_initcall(netlink_proto_init);
+core_initcall_sync(netlink_proto_init);
 
 EXPORT_SYMBOL(netlink_ack);
 EXPORT_SYMBOL(netlink_run_queue);
