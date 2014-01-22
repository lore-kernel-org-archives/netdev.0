From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] bonding: Don't allow bond devices to change network
 namespaces.
Date: Wed, 22 Jan 2014 10:41:06 +0100
Message-ID: <20140122094106.GB2814@minipsycho.orion>
References: <1390382190-1604-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fubar@us.ibm.com, vfalico@redhat.com, andy@greyhouse.net,
	davem@davemloft.net, netdev@vger.kernel.org
To: Chen Weilong <chenweilong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:34181 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755040AbaAVJlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 04:41:09 -0500
Received: by mail-ee0-f52.google.com with SMTP id e53so4724790eek.11
        for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 01:41:08 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1390382190-1604-1-git-send-email-chenweilong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jan 22, 2014 at 10:16:30AM CET, chenweilong@huawei.com wrote:
>From: Weilong Chen <chenweilong@huawei.com>
>
>Like bridge, bonding as netdevice doesn't cross netns boundaries.
>
>Bonding ports and bonding itself live in same netns.

I think should should be done for team as well. Openvs already
has this. I believe that for vlans it is ok to change ns, right?

>
>Signed-off-by: Weilong Chen <chenweilong@huawei.com>
>---
> drivers/net/bonding/bond_main.c | 3 +++
> 1 file changed, 3 insertions(+)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index f00dd45..897d153 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -3916,6 +3916,9 @@ void bond_setup(struct net_device *bond_dev)
> 	 * capable
> 	 */
> 
>+	/* Don't allow bond devices to change network namespaces. */
>+	bond_dev->features |= NETIF_F_NETNS_LOCAL;
>+
> 	bond_dev->hw_features = BOND_VLAN_FEATURES |
> 				NETIF_F_HW_VLAN_CTAG_TX |
> 				NETIF_F_HW_VLAN_CTAG_RX |
>-- 
>1.7.12
>
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
