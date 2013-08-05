From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [net-next,3/3] bonding: unwind on bond_add_vlan add failure
Date: Mon, 5 Aug 2013 23:59:21 +0200
Message-ID: <20130805215921.GA14299@redhat.com>
References: <1375709304-16778-4-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	davem@davemloft.net
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46021 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754967Ab3HEV7c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Aug 2013 17:59:32 -0400
Content-Disposition: inline
In-Reply-To: <1375709304-16778-4-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 05, 2013 at 03:28:24PM +0200, nikolay@redhat.com wrote:
>From: Nikolay Aleksandrov <Nikolay Aleksandrov nikolay@redhat.com>
>
>In case of bond_add_vlan() failure currently we'll have the vlan's
>refcnt bumped up in all slaves, but it will never go down because it
>failed to get added to the bond, so properly unwind the added vlan if
>bond_add_vlan fails.
>
>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

In case patch 1/3 from series goes in... Otherwise I think it will be
needed to patch bond_vlan_rx_add_vid().

Acked-by: Veaceslav Falico <vfalico@redhat.com>

>
>---
>drivers/net/bonding/bond_main.c | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index ed1d261..0f9ca7e 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -456,13 +456,13 @@ static int __bond_vlan_rx_add_vid(struct net_device *bond_dev,
> 	if (res) {
> 		pr_err("%s: Error: Failed to add vlan id %d\n",
> 		       bond_dev->name, vid);
>-		return res;
>+		goto unwind;
> 	}
>
> 	return 0;
>
> unwind:
>-	/* unwind from head to the slave that failed */
>+	/* unwind from the slave that failed */
> 	bond_for_each_slave_continue_reverse(bond, slave)
> 		vlan_vid_del(slave->dev, proto, vid);
>
