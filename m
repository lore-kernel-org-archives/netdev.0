From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 3/4] appletalk: convert printks to pr_<level>
Date: Sat, 15 Feb 2014 00:45:53 +0300
Message-ID: <52FE8E91.2040105@cogentembedded.com>
References: <1392363826-8256-1-git-send-email-wangweidong1@huawei.com> <1392363826-8256-4-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Wang Weidong <wangweidong1@huawei.com>, acme@ghostprotocols.net,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:59668 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751845AbaBNUpu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 15:45:50 -0500
Received: by mail-lb0-f176.google.com with SMTP id w7so9587834lbi.21
        for <netdev@vger.kernel.org>; Fri, 14 Feb 2014 12:45:48 -0800 (PST)
In-Reply-To: <1392363826-8256-4-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 02/14/2014 10:43 AM, Wang Weidong wrote:

> Prefer pr_<level> then printk(LEVEL).

> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>

[...]
> diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
> index 06e0d19..9189d3c 100644
> --- a/net/appletalk/ddp.c
> +++ b/net/appletalk/ddp.c
> @@ -704,9 +704,9 @@ static int atif_ioctl(int cmd, void __user *arg)
>   		if ((dev->flags & IFF_POINTOPOINT) &&
>   		    atalk_find_interface(sa->sat_addr.s_net,
>   					 sa->sat_addr.s_node)) {
> -			printk(KERN_DEBUG "AppleTalk: point-to-point "
> -			       "interface added with "
> -			       "existing address\n");
> +			pr_debug("AppleTalk: point-to-point "
> +				 "interface added with "
> +				 "existing address\n");
>   			add_route = 0;
>   		}
>
[...]
> @@ -1329,8 +1328,8 @@ static int atalk_route_packet(struct sk_buff *skb, struct net_device *dev,
>   		 * needs to be broadcast onto the default network?
>   		 */
>   		if (dev->type == ARPHRD_PPP)
> -			printk(KERN_DEBUG "AppleTalk: didn't forward broadcast "
> -					  "packet received from PPP iface\n");
> +			pr_debug("AppleTalk: didn't forward broadcast "
> +				 "packet received from PPP iface\n");

    pr_debug() is not equivalent to printk(KERN_DEBUG). It will only print a 
message if DEBUG is defined or if dynamic debugging is enabled.

WBR, Sergei
