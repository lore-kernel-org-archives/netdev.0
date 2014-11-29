From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net] bond: Check length of IFLA_BOND_ARP_IP_TARGET attributes
Date: Sat, 29 Nov 2014 09:53:27 -0800
Message-ID: <547A0817.6010804@gmail.com>
References: <a7c193909c30dbc19b4f279a3f7ba757107641d3.1417044113.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Scott Feldman <sfeldma@cumulusnetworks.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:51839 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751713AbaK2Rxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Nov 2014 12:53:38 -0500
Received: by mail-ob0-f180.google.com with SMTP id wp4so6101456obc.25
        for <netdev@vger.kernel.org>; Sat, 29 Nov 2014 09:53:38 -0800 (PST)
In-Reply-To: <a7c193909c30dbc19b4f279a3f7ba757107641d3.1417044113.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/26/2014 03:22 PM, Thomas Graf wrote:
> Fixes: 7f28fa10 ("bonding: add arp_ip_target netlink support")
> Reported-by: John Fastabend <john.fastabend@gmail.com>
> Cc: Scott Feldman <sfeldma@cumulusnetworks.com>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> ---
>   drivers/net/bonding/bond_netlink.c | 7 ++++++-
>   1 file changed, 6 insertions(+), 1 deletion(-)
>

Looks good thanks! For what its worth...

Acked-by: John Fastabend <john.r.fastabend@intel.com>

> diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
> index c13d83e..45f09a6 100644
> --- a/drivers/net/bonding/bond_netlink.c
> +++ b/drivers/net/bonding/bond_netlink.c
> @@ -225,7 +225,12 @@ static int bond_changelink(struct net_device *bond_dev,
>
>   		bond_option_arp_ip_targets_clear(bond);
>   		nla_for_each_nested(attr, data[IFLA_BOND_ARP_IP_TARGET], rem) {
> -			__be32 target = nla_get_be32(attr);
> +			__be32 target;
> +
> +			if (nla_len(attr) < sizeof(target))
> +				return -EINVAL;
> +
> +			target = nla_get_be32(attr);
>
>   			bond_opt_initval(&newval, (__force u64)target);
>   			err = __bond_opt_set(bond, BOND_OPT_ARP_TARGETS,
>


-- 
John Fastabend         Intel Corporation
