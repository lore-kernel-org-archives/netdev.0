From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Possible bug in bonding driver (with VLAN in ALB mode)
Date: Tue, 21 Oct 2008 11:12:35 -0700
Message-ID: <1830.1224612755@death.nxdomain.ibm.com>
References: <48FE0EEB.7050503@anduras.de>
Cc: netdev@vger.kernel.org
To: Sven Anders <anders@anduras.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:42855 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751478AbYJUSM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 14:12:56 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m9LICtA8013333
	for <netdev@vger.kernel.org>; Tue, 21 Oct 2008 14:12:55 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9LICft6076366
	for <netdev@vger.kernel.org>; Tue, 21 Oct 2008 12:12:42 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9LICeZN018709
	for <netdev@vger.kernel.org>; Tue, 21 Oct 2008 12:12:41 -0600
In-reply-to: <48FE0EEB.7050503@anduras.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sven Anders <anders@anduras.de> wrote:
[...]
>After an ARP request was sent (by the router) in the "rlb_arp_xmit()",
>the "rlb_choose_channel()" function is called and reserves a
>(placeholder) entry in the hash table. According to the comment this
>entry will be updated later by the corresponding ARP reply.
>Shortly afterwards we see an ARP reply package on the VLAN interface.
>But it is never processed by "rlb_arp_recv()", because this function
>only receives arp packages from bond0 and so the entry is never
>updated.

	Can you try this patch and tell me if it fixes the problem?

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index ade5f3f..500a207 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -815,7 +815,7 @@ static int rlb_initialize(struct bonding *bond)
 
 	/*initialize packet type*/
 	pk_type->type = __constant_htons(ETH_P_ARP);
-	pk_type->dev = bond->dev;
+	pk_type->dev = NULL;
 	pk_type->func = rlb_arp_recv;
 
 	/* register to receive ARPs */


	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
