From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next 3/4] bonding: do not save non-existent device to
 bond primary in sysfs
Date: Thu, 9 Jan 2014 12:47:48 +0100
Message-ID: <20140109114748.GG5786@redhat.com>
References: <52CE8616.2010902@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28294 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750905AbaAILuu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 06:50:50 -0500
Content-Disposition: inline
In-Reply-To: <52CE8616.2010902@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 09, 2014 at 07:20:54PM +0800, Ding Tianhong wrote:
>Do not save non-existent device to bond primary in sysfs.

Again, no - this interface might be enslaved after we've set the
parameters, as it usually does.

>
>Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>---
> drivers/net/bonding/bond_options.c | 6 ++++++
> 1 file changed, 6 insertions(+)
>
>diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
>index 945a666..9b4518f 100644
>--- a/drivers/net/bonding/bond_options.c
>+++ b/drivers/net/bonding/bond_options.c
>@@ -501,6 +501,12 @@ int bond_option_primary_set(struct bonding *bond, const char *primary)
> 		goto out;
> 	}
>
>+	if (!__dev_get_by_name(dev_net(bond->dev), primary)) {
>+		pr_err("%s: unable to set non-existent device %s to primary.\n",
>+		       bond->dev->name, primary);
>+		goto out;
>+	}
>+
> 	bond_for_each_slave(bond, slave, iter) {
> 		if (strncmp(slave->dev->name, primary, IFNAMSIZ) == 0) {
> 			pr_info("%s: Setting %s as primary slave.\n",
>-- 
>1.8.0
>
>
