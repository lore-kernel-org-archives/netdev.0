From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net] bonding: set correct vlan id for alb xmit path
Date: Wed, 12 Mar 2014 11:37:00 +0100
Message-ID: <20140312103700.GA5442@redhat.com>
References: <531E6D77.60808@huawei.com>
 <5320298F.2010101@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8262 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750981AbaCLKhN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Mar 2014 06:37:13 -0400
Content-Disposition: inline
In-Reply-To: <5320298F.2010101@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 12, 2014 at 05:31:59PM +0800, Ding Tianhong wrote:
>The commit d3ab3ffd1d728d7ee77340e7e7e2c7cfe6a4013e
>(bonding: use rlb_client_info->vlan_id instead of ->tag)
>remove the rlb_client_info->tag, but occur some issues,
>The vlan_get_tag() will return 0 for success and -EINVAL for
>error, so the client_info->vlan_id always be set to 0 if the
>vlan_get_tag return 0 for success, so the client_info would
>never get a correct vlan id.
>
>We should only set the vlan id to 0 when the vlan_get_tag return error.
>
>Fixes: d3ab3ffd1d7 (bonding: use rlb_client_info->vlan_id instead of ->tag)
>
>CC: Ding Tianhong <dingtianhong@huawei.com>
>CC: Jay Vosburgh <fubar@us.ibm.com>
>CC: Andy Gospodarek <andy@greyhouse.net>
>Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

Acked-by: Veaceslav Falico <vfalico@redhat.com>

>---
> drivers/net/bonding/bond_alb.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
>diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
>index a2c4747..e8f133e 100644
>--- a/drivers/net/bonding/bond_alb.c
>+++ b/drivers/net/bonding/bond_alb.c
>@@ -730,7 +730,7 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
> 			client_info->ntt = 0;
> 		}
>
>-		if (!vlan_get_tag(skb, &client_info->vlan_id))
>+		if (vlan_get_tag(skb, &client_info->vlan_id))
> 			client_info->vlan_id = 0;
>
> 		if (!client_info->assigned) {
>-- 
>1.8.0
>
>
>
