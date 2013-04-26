From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] openvswitch: Remove unneeded ovs_netdev_get_ifindex()
Date: Fri, 26 Apr 2013 17:41:51 +0400
Message-ID: <517A841F.6080107@cogentembedded.com>
References: <a59b1675cc29cd2897bdf1fb6ae34bfd0971fbb7.1366980015.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, netdev@vger.kernel.org, dev@openvswitch.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:43785 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755459Ab3DZNnJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Apr 2013 09:43:09 -0400
Received: by mail-lb0-f169.google.com with SMTP id p11so3802559lbi.28
        for <netdev@vger.kernel.org>; Fri, 26 Apr 2013 06:43:07 -0700 (PDT)
In-Reply-To: <a59b1675cc29cd2897bdf1fb6ae34bfd0971fbb7.1366980015.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 26-04-2013 16:40, Thomas Graf wrote:

> The only user is get_dpifindex(), no need to redirect via the port
> operations.

> Signed-off-by: Thomas Graf <tgraf@suug.ch>
[...]

> diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
> index 74a5fe6..965c059 100644
> --- a/net/openvswitch/datapath.c
> +++ b/net/openvswitch/datapath.c
> @@ -150,9 +150,10 @@ static int get_dpifindex(struct datapath *dp)
>   	rcu_read_lock();
>
>   	local = ovs_vport_rcu(dp, OVSP_LOCAL);
> -	if (local)
> -		ifindex = local->ops->get_ifindex(local);
> -	else
> +	if (local) {
> +		const struct netdev_vport *vport = netdev_vport_priv(local);

    Empty line after declaration wouldn't hurt.

> +		ifindex = vport->dev->ifindex;
> +	} else
>   		ifindex = 0;
>
>   	rcu_read_unlock();

WBR, Sergei
