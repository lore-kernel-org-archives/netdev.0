From: Linda Walsh <lkml@tlinx.org>
Subject: upgrade to 3.8.1 : BUG Scheduling while atomic in bonding driver:
Date: Thu, 07 Mar 2013 00:52:35 -0800
Message-ID: <51385553.8060003@tlinx.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: LKML <linux-lkml@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ishtar.tlinx.org ([173.164.175.65]:39621 "EHLO
	Ishtar.sc.tlinx.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755002Ab3CGIwq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 03:52:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>




I am *not* seeing the bug in 3.8.2 with the 2nd patch applied (in
addition to the first)...


Michael Wang wrote:
>
>
> And both bond_enslave() and bond_mii_monitor() are using bond_update_speed_duplex()
> with preempt disabled.
>
> Along with the changes in bond_enslave(), I think you also need this (untested):
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 11d01d6..9af143a 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -2373,7 +2373,9 @@ static void bond_miimon_commit(struct bonding *bond)
>                                 bond_set_backup_slave(slave);
>                         }
>  
> +                       read_unlock(&bond->lock);
>                         bond_update_speed_duplex(slave);
> +                       read_lock(&bond->lock);
>  
>                         pr_info("%s: link status definitely up for interface %s, %u Mbps %s duplex.\n",
>                                 bond->dev->name, slave->dev->name,
>
>
> Regards,
> Michael Wang
>
>   
>
