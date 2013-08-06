From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [net-next,v2,2/2] bonding: unwind on bond_add_vlan failure
Date: Tue, 6 Aug 2013 14:11:42 +0200
Message-ID: <20130806121142.GP22756@redhat.com>
References: <1375785616-5349-3-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com,
	davem@davemloft.net
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56481 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756287Ab3HFMM5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 08:12:57 -0400
Content-Disposition: inline
In-Reply-To: <1375785616-5349-3-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 06, 2013 at 12:40:16PM +0200, nikolay@redhat.com wrote:
>From: Nikolay Aleksandrov <Nikolay Aleksandrov nikolay@redhat.com>
>
>In case of bond_add_vlan() failure currently we'll have the vlan's
>refcnt bumped up in all slaves, but it will never go down because it
>failed to get added to the bond, so properly unwind the added vlan if
>bond_add_vlan fails.
>
>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

Acked-by: Veaceslav Falico <vfalico@redhat.com>

>
>---
>v2: no changes
>
> drivers/net/bonding/bond_main.c | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 78b0aeb..4264a76 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -455,13 +455,13 @@ static int bond_vlan_rx_add_vid(struct net_device *bond_dev,
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
