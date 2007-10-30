From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 1/1][IPV6] resend:  remove duplicate call to proc_net_remove
Date: Tue, 30 Oct 2007 17:23:45 +0100
Message-ID: <20071030162450.257974469@mai.toulouse-stg.fr.ibm.com>
References: <20071030162344.297260466@mai.toulouse-stg.fr.ibm.com>
Cc: containers@lists.osdl.org, netdev@vger.kernel.org
To: davem@davemloft.net, ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:42950 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759538AbXJ3Q1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 12:27:16 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id l9UGRFm5124068
	for <netdev@vger.kernel.org>; Tue, 30 Oct 2007 16:27:15 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9UGRFtT2232386
	for <netdev@vger.kernel.org>; Tue, 30 Oct 2007 17:27:15 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9UGRE3U014673
	for <netdev@vger.kernel.org>; Tue, 30 Oct 2007 17:27:15 +0100
Content-Disposition: inline; filename=fix-proc-net-remove-called-twice.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The file /proc/net/if_inet6 is removed twice.
First time in:
        inet6_exit
             ->addrconf_cleanup
And followed a few lines after by:
        inet6_exit
             -> if6_proc_exit

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/ipv6/addrconf.c |    4 ----
 1 file changed, 4 deletions(-)

Index: net-2.6/net/ipv6/addrconf.c
===================================================================
--- net-2.6.orig/net/ipv6/addrconf.c
+++ net-2.6/net/ipv6/addrconf.c
@@ -4288,8 +4288,4 @@ void __exit addrconf_cleanup(void)
 	del_timer(&addr_chk_timer);
 
 	rtnl_unlock();
-
-#ifdef CONFIG_PROC_FS
-	proc_net_remove(&init_net, "if_inet6");
-#endif
 }

-- 
