From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [patch net-next] bonding: add slave netlink policy and put slave-related
 ops together
Date: Fri, 05 Sep 2014 12:21:06 +0200
Message-ID: <54098E92.6020207@redhat.com>
References: <1409909794-7664-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, j.vosburgh@gmail.com, vfalico@gmail.com,
	andy@greyhouse.net
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10612 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756573AbaIEKVT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2014 06:21:19 -0400
In-Reply-To: <1409909794-7664-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/09/14 11:36, Jiri Pirko wrote:
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>   drivers/net/bonding/bond_netlink.c | 9 +++++++--
>   1 file changed, 7 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
> index 1570dea..e1489d9 100644
> --- a/drivers/net/bonding/bond_netlink.c
> +++ b/drivers/net/bonding/bond_netlink.c
> @@ -96,6 +96,10 @@ static const struct nla_policy bond_policy[IFLA_BOND_MAX + 1] = {
>   	[IFLA_BOND_AD_INFO]		= { .type = NLA_NESTED },
>   };
>
> +static const struct nla_policy bond_slave_policy[IFLA_BOND_SLAVE_MAX + 1] = {
> +	[IFLA_BOND_SLAVE_QUEUE_ID]	= { .type = NLA_U16 },
> +};
> +
>   static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
>   {
>   	if (tb[IFLA_ADDRESS]) {
> @@ -580,17 +584,18 @@ struct rtnl_link_ops bond_link_ops __read_mostly = {
>   	.priv_size		= sizeof(struct bonding),
>   	.setup			= bond_setup,
>   	.maxtype		= IFLA_BOND_MAX,
> -	.slave_maxtype		= IFLA_BOND_SLAVE_MAX,
>   	.policy			= bond_policy,
>   	.validate		= bond_validate,
>   	.newlink		= bond_newlink,
>   	.changelink		= bond_changelink,
> -	.slave_changelink	= bond_slave_changelink,
>   	.get_size		= bond_get_size,
>   	.fill_info		= bond_fill_info,
>   	.get_num_tx_queues	= bond_get_num_tx_queues,
>   	.get_num_rx_queues	= bond_get_num_tx_queues, /* Use the same number
>   							     as for TX queues */
> +	.slave_maxtype		= IFLA_BOND_SLAVE_MAX,
> +	.slave_policy		= bond_slave_policy,
> +	.slave_changelink	= bond_slave_changelink,
>   	.get_slave_size		= bond_get_slave_size,
>   	.fill_slave_info	= bond_fill_slave_info,
>   };
>

Right, the validation policy, I knew I forgot something :-)

Acked-by: Nikolay Aleksandrov <nikolay@redhat.com>
