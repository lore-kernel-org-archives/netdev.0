From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bonding: fix destruction of bond with devices
 different from arphrd_ether
Date: Mon, 20 Jul 2015 12:56:33 -0700 (PDT)
Message-ID: <20150720.125633.1368284956560368161.davem@davemloft.net>
References: <55A69D17.5030800@cumulusnetworks.com>
	<1436989971-32761-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com,
	gospo@cumulusnetworks.com, vfalico@gmail.com,
	clsoto@linux.vnet.ibm.com, ebiederm@xmission.com,
	nikolay@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50562 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756372AbbGTT4f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 15:56:35 -0400
In-Reply-To: <1436989971-32761-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Wed, 15 Jul 2015 21:52:51 +0200

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> When the bonding is being unloaded and the netdevice notifier is
> unregistered it executes NETDEV_UNREGISTER for each device which should
> remove the bond's proc entry but if the device enslaved is not of
> ARPHRD_ETHER type and is in front of the bonding, it may execute
> bond_release_and_destroy() first which would release the last slave and
> destroy the bond device leaving the proc entry and thus we will get the
> following error (with dynamic debug on for bond_netdev_event to see the
> events order):
 ...
> Thus remove the proc entry manually if bond_release_and_destroy() is
> used. Because of the checks in bond_remove_proc_entry() it's not a
> problem for a bond device to change namespaces (the bug fixed by the
> Fixes commit) but since commit
> f9399814927ad ("bonding: Don't allow bond devices to change network
> namespaces.") that can't happen anyway.
> 
> Reported-by: Carol Soto <clsoto@linux.vnet.ibm.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Fixes: a64d49c3dd50 ("bonding: Manage /proc/net/bonding/ entries from
>                       the netdev events")

Applied and queued up for -stable, thanks.
