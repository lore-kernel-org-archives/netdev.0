From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [IPV6] cleanup : remove proc_net_remove called twice
Date: Tue, 30 Oct 2007 13:55:57 +0100
Message-ID: <472729DD.4070504@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>
To: David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([195.212.29.139]:47575 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752416AbXJ3M6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 08:58:33 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate6.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l9UCwWmc380108
	for <netdev@vger.kernel.org>; Tue, 30 Oct 2007 12:58:32 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9UCwVAS2129948
	for <netdev@vger.kernel.org>; Tue, 30 Oct 2007 12:58:31 GMT
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9UCwPxp011367
	for <netdev@vger.kernel.org>; Tue, 30 Oct 2007 12:58:25 GMT
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
-       proc_net_remove(&init_net, "if_inet6");
-#endif
  }
