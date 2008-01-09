From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 0/3] bonding: 3 fixes for 2.6.24
Date: Tue, 08 Jan 2008 23:58:34 -0800
Message-ID: <17850.1199865514@death>
References: <11997574203125-git-send-email-fubar@us.ibm.com> <Pine.LNX.4.64.0801081949290.1135@bizon.gios.gov.pl> <29560.1199820632@death> <Pine.LNX.4.64.0801090732490.1135@bizon.gios.gov.pl>
Cc: netdev@vger.kernel.org, Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Krzysztof Oledzki <olel@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:33615 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751941AbYAIH7B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 02:59:01 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m097wqYT002114
	for <netdev@vger.kernel.org>; Wed, 9 Jan 2008 02:58:52 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m097wqlr132060
	for <netdev@vger.kernel.org>; Wed, 9 Jan 2008 00:58:52 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m097wpwN007347
	for <netdev@vger.kernel.org>; Wed, 9 Jan 2008 00:58:52 -0700
In-reply-to: <Pine.LNX.4.64.0801090732490.1135@bizon.gios.gov.pl> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krzysztof Oledzki <olel@ans.pl> wrote:

>Fine. Just let you know that someone test your patches and everything
>works, except mentioned problem.

	And I appreciate it; I just wanted to make sure our many fans
following along at home didn't misunderstand.

	Could you let me know if the patch below make the lockdep
warning go away?  This applies on top of the previous three, although it
should be trivial to do by hand.

	I'm still checking to make sure this is safe with regard to
mutexing the bonding structures, but it would be good to know if it
eliminates the warning.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com


diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 77d004d..1baaadc 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3937,8 +3937,6 @@ static void bond_set_multicast_list(struct net_device *bond_dev)
 	struct bonding *bond = bond_dev->priv;
 	struct dev_mc_list *dmi;
 
-	write_lock_bh(&bond->lock);
-
 	/*
 	 * Do promisc before checking multicast_mode
 	 */
@@ -3978,8 +3976,6 @@ static void bond_set_multicast_list(struct net_device *bond_dev)
 	/* save master's multicast list */
 	bond_mc_list_destroy(bond);
 	bond_mc_list_copy(bond_dev->mc_list, bond, GFP_ATOMIC);
-
-	write_unlock_bh(&bond->lock);
 }
 
 /*
