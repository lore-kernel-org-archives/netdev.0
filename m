From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: [patch net-next] bonding: remove no longer relevant vlan warnings
Date: Wed, 2 Jul 2014 14:03:08 +0200
Message-ID: <20140702120308.GA2596@mikrodark.usersys.redhat.com>
References: <1404294938-9968-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, davem@davemloft.net, j.vosburgh@gmail.com,
	andy@greyhouse.net, teg@jklm.no, jay.vosburgh@canonical.com,
	mkubecek@suse.cz
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:53039 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751524AbaGBMEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 08:04:04 -0400
Received: by mail-we0-f174.google.com with SMTP id u57so11231897wes.19
        for <netdev@vger.kernel.org>; Wed, 02 Jul 2014 05:04:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1404294938-9968-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 02, 2014 at 11:55:38AM +0200, Jiri Pirko wrote:
>These warnings are no longer relevant. Even when last slave is
>removed, there is a valid address assigned to bond (random).
>The correct functionality of vlans is ensured by maintaining unicast
>list in vlan_sync_address().
>
>Suggested-by: Jay Vosburgh <jay.vosburgh@canonical.com>
>Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Thanks for following up on this.

Acked-by: Veaceslav Falico <vfalico@gmail.com>

>---
> drivers/net/bonding/bond_main.c | 7 -------
> 1 file changed, 7 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index ffefb70..09dc3ef 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -1754,13 +1754,6 @@ static int __bond_release_one(struct net_device *bond_dev,
> 	if (!bond_has_slaves(bond)) {
> 		bond_set_carrier(bond);
> 		eth_hw_addr_random(bond_dev);
>-
>-		if (vlan_uses_dev(bond_dev)) {
>-			pr_warn("%s: Warning: clearing HW address of %s while it still has VLANs\n",
>-				bond_dev->name, bond_dev->name);
>-			pr_warn("%s: When re-adding slaves, make sure the bond's HW address matches its VLANs\n",
>-				bond_dev->name);
>-		}
> 	}
>
> 	unblock_netpoll_tx();
>-- 
>1.9.0
>
