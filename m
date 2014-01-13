From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net 2/2] bonding: rename the dev upper link if the master's,
 name changed
Date: Mon, 13 Jan 2014 21:54:10 +0400
Message-ID: <52D42842.5010709@cogentembedded.com>
References: <52D3E55B.8080401@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Ding Tianhong <dingtianhong@huawei.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:44694 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752172AbaAMRyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 12:54:12 -0500
Received: by mail-la0-f52.google.com with SMTP id c6so1652785lan.11
        for <netdev@vger.kernel.org>; Mon, 13 Jan 2014 09:54:11 -0800 (PST)
In-Reply-To: <52D3E55B.8080401@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-01-2014 17:08, Ding Tianhong wrote:

> The bond_maste_rename() will rename the links for slave dev's upper dev link,

    s/maste/master/.

> if faild, it will rollback and rename the new name to old name for slave dev.

    s/faild/failed/.

> Add a new parameter called name to save the old bonding name in struct bonding.

> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> ---
>   drivers/net/bonding/bond_main.c | 35 +++++++++++++++++++++++++++++++++++
>   drivers/net/bonding/bonding.h   |  1 +
>   2 files changed, 36 insertions(+)

> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 4b8c58b..8c044c0 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -2799,11 +2799,41 @@ re_arm:
>
>   /*-------------------------- netdev event handling --------------------------*/
>
> +static int bond_master_rename(struct bonding *bond)
> +{
> +	struct slave *slave;
> +	struct list_head *iter;
> +	char ori_linkname[IFNAMSIZ + 7], new_linkname[IFNAMSIZ + 7];

    Perhaps s/ori/old/ is better?

> +	int err = 0;
> +
> +	sprintf(ori_linkname, "upper_%s", bond->name);
> +	sprintf(new_linkname, "upper_%s", bond->dev->name);
> +
> +	bond_for_each_slave(bond, slave, iter) {
> +

    No need for this empty line, I think.

> +		err = netdev_upper_dev_rename(slave->dev, bond->dev, ori_linkname,
> +					new_linkname);

    The continuation line should start right under 'slave' on the broken up line.

WBR, Sergei
