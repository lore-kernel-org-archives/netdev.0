From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH net-next v2 1/5] bonding: update bond carrier state when min_links option changes
Date: Mon, 26 Jan 2015 16:29:00 -0800
Message-ID: <21553.1422318540@famine>
References: <1422253021-3798-1-git-send-email-jtoppins@cumulusnetworks.com> <1422253021-3798-2-git-send-email-jtoppins@cumulusnetworks.com>
Cc: Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:60057 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756336AbbA0A3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 19:29:07 -0500
In-reply-to: <1422253021-3798-2-git-send-email-jtoppins@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jonathan Toppins <jtoppins@cumulusnetworks.com> wrote:

>Cc: Andy Gospodarek <gospo@cumulusnetworks.com>
>Signed-off-by: Jonathan Toppins <jtoppins@cumulusnetworks.com>

Signed-off-by: Jay Vosburgh <jay.vosburgh@canonical.com>


> drivers/net/bonding/bond_main.c    |    2 +-
> drivers/net/bonding/bond_options.c |    1 +
> include/net/bonding.h              |    1 +
> 3 files changed, 3 insertions(+), 1 deletion(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 0dceba1..02ffedb 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -334,7 +334,7 @@ static int bond_vlan_rx_kill_vid(struct net_device *bond_dev,
>  *
>  * Returns zero if carrier state does not change, nonzero if it does.
>  */
>-static int bond_set_carrier(struct bonding *bond)
>+int bond_set_carrier(struct bonding *bond)
> {
> 	struct list_head *iter;
> 	struct slave *slave;
>diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
>index 9bd538d4..4df2894 100644
>--- a/drivers/net/bonding/bond_options.c
>+++ b/drivers/net/bonding/bond_options.c
>@@ -1181,6 +1181,7 @@ static int bond_option_min_links_set(struct bonding *bond,
> 	netdev_info(bond->dev, "Setting min links value to %llu\n",
> 		    newval->value);
> 	bond->params.min_links = newval->value;
>+	bond_set_carrier(bond);
> 
> 	return 0;
> }
>diff --git a/include/net/bonding.h b/include/net/bonding.h
>index 983a94b..29f53ea 100644
>--- a/include/net/bonding.h
>+++ b/include/net/bonding.h
>@@ -525,6 +525,7 @@ void bond_sysfs_slave_del(struct slave *slave);
> int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev);
> int bond_release(struct net_device *bond_dev, struct net_device *slave_dev);
> u32 bond_xmit_hash(struct bonding *bond, struct sk_buff *skb);
>+int bond_set_carrier(struct bonding *bond);
> void bond_select_active_slave(struct bonding *bond);
> void bond_change_active_slave(struct bonding *bond, struct slave *new_active);
> void bond_create_debugfs(void);
>-- 
>1.7.10.4
>
