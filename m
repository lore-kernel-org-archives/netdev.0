From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next 3/3] bonding: cleanup some redundant code and
 wrong variables
Date: Wed, 22 Jan 2014 15:28:23 +0100
Message-ID: <52DFD587.4070109@redhat.com>
References: <52DF8DC2.2030609@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Ding Tianhong <dingtianhong@huawei.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31628 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755319AbaAVOc5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jan 2014 09:32:57 -0500
In-Reply-To: <52DF8DC2.2030609@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/22/2014 10:22 AM, Ding Tianhong wrote:
> The dev_set_mac_address() will check the dev->netdev_ops->ndo_set_mac_address,
> so no need to check it in bond_set_mac_address().
> 
> Fix the wrong variables for pr_err().
> 
> Cc: Jay Vosburgh <fubar@us.ibm.com>
> Cc: Veaceslav Falico <vfalico@redhat.com>
> Cc: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> ---
>  drivers/net/bonding/bond_main.c | 10 +---------
>  1 file changed, 1 insertion(+), 9 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index ce0f5c0..9d92f46 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -3509,15 +3509,7 @@ static int bond_set_mac_address(struct net_device *bond_dev, void *addr)
>  	 */
>  
>  	bond_for_each_slave(bond, slave, iter) {
> -		const struct net_device_ops *slave_ops = slave->dev->netdev_ops;
>  		pr_debug("slave %p %s\n", slave, slave->dev->name);
> -
> -		if (slave_ops->ndo_set_mac_address == NULL) {
> -			res = -EOPNOTSUPP;
> -			pr_debug("EOPNOTSUPP %s\n", slave->dev->name);
> -			goto unwind;
> -		}
> -
>  		res = dev_set_mac_address(slave->dev, addr);
>  		if (res) {
>  			/* TODO: consider downing the slave
> @@ -4317,7 +4309,7 @@ static int bond_check_params(struct bond_params *params)
>  						      fail_over_mac_tbl);
>  		if (fail_over_mac_value == -1) {
>  			pr_err("Error: invalid fail_over_mac \"%s\"\n",
> -			       arp_validate == NULL ? "NULL" : arp_validate);
> +			       fail_over_mac == NULL ? "NULL" : fail_over_mac);
>  			return -EINVAL;
>  		}
My option API changes include a fix for this which also removes the NULL check
as it's already checked earlier if fail_over_mac is != NULL. If you'd like to
fix this yourself I think you can also skip the NULL check when printing the error.

Cheers,
 Nik
>  
> 
