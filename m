From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [net-2.6 - patch 1/1] ipv6 : Fix useless proc net sockstat6 removal
Date: Mon, 28 Jul 2008 23:41:38 +0200
Message-ID: <488E3D12.7010708@fr.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090208050103030707040704"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:64520 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753521AbYG1VmB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2008 17:42:01 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id m6SLfleC453604
	for <netdev@vger.kernel.org>; Mon, 28 Jul 2008 21:41:47 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6SLflC53481700
	for <netdev@vger.kernel.org>; Mon, 28 Jul 2008 23:41:47 +0200
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6SLflCX017583
	for <netdev@vger.kernel.org>; Mon, 28 Jul 2008 23:41:47 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090208050103030707040704
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



--------------090208050103030707040704
Content-Type: text/plain;
 name="fix-remove-proc-sockstat6.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="fix-remove-proc-sockstat6.patch"

Subject: ipv6 : Fix useless proc net sockstat6 removal
From: Daniel Lezcano <dlezcano@fr.ibm.com>

This call is no longer needed, sockstat6 is per namespace so it is
removed at the namespace subsystem destruction.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/ipv6/proc.c |    1 -
 1 file changed, 1 deletion(-)

Index: net-2.6/net/ipv6/proc.c
===================================================================
--- net-2.6.orig/net/ipv6/proc.c
+++ net-2.6/net/ipv6/proc.c
@@ -286,7 +286,6 @@ proc_net_fail:
 
 void ipv6_misc_proc_exit(void)
 {
-	proc_net_remove(&init_net, "sockstat6");
 	proc_net_remove(&init_net, "dev_snmp6");
 	proc_net_remove(&init_net, "snmp6");
 	unregister_pernet_subsys(&ipv6_proc_ops);

--------------090208050103030707040704--
