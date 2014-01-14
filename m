From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next 2/3] bonding: clean the primary slave if there
 is no slave matching new primary
Date: Tue, 14 Jan 2014 07:42:28 +0100
Message-ID: <20140114064227.GC7798@redhat.com>
References: <52D4A2CC.6010907@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1575 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751434AbaANGpb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 01:45:31 -0500
Content-Disposition: inline
In-Reply-To: <52D4A2CC.6010907@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 14, 2014 at 10:37:00AM +0800, Ding Tianhong wrote:
>If the new primay is not matching any slave in the bond, the bond should
>record it to params, clean the primary slave and select a new active slave.

This one looks good.

>
>Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>---
> drivers/net/bonding/bond_options.c | 6 ++++++
> 1 file changed, 6 insertions(+)
>
>diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
>index 945a666..0ee0bfe 100644
>--- a/drivers/net/bonding/bond_options.c
>+++ b/drivers/net/bonding/bond_options.c
>@@ -512,6 +512,12 @@ int bond_option_primary_set(struct bonding *bond, const char *primary)
> 		}
> 	}
>
>+	if (bond->primary_slave) {
>+		pr_info("%s: Setting primary slave to None.\n",
>+			bond->dev->name);
>+		bond->primary_slave = NULL;
>+		bond_select_active_slave(bond);
>+	}
> 	strncpy(bond->params.primary, primary, IFNAMSIZ);
> 	bond->params.primary[IFNAMSIZ - 1] = 0;
>
>-- 
>1.8.0
>
>
