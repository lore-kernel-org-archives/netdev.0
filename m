From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 16/16] tipc: make netlink support net namespace
Date: Fri, 09 Jan 2015 16:42:19 +0300
Message-ID: <54AFDABB.3080103@cogentembedded.com>
References: <1420788433-17960-1-git-send-email-ying.xue@windriver.com> <1420788433-17960-17-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Tero.Aho@coriant.com,
	Paul.Gortmaker@windriver.com, erik.hugne@ericsson.com,
	richard.alpe@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: Ying Xue <ying.xue@windriver.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:44863 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756861AbbAINmV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 08:42:21 -0500
Received: by mail-la0-f42.google.com with SMTP id gd6so14578835lab.1
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 05:42:20 -0800 (PST)
In-Reply-To: <1420788433-17960-17-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 1/9/2015 10:27 AM, Ying Xue wrote:

> Currently tipc module only allows users sitting on "init_net" namespace
> to configure it through netlink interface. But now almost each tipc
> component is able to be aware of net namespace, so it's time to open
> the permission for users residing in other namespaces, allowing them
> to configure their own tipc stack instance through netlink interface.

> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> Tested-by: Tero Aho <Tero.Aho@coriant.com>
> Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
> ---
>   net/tipc/netlink.c |    7 +++++--
>   1 file changed, 5 insertions(+), 2 deletions(-)

> diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
> index 282b596..fe0f513 100644
> --- a/net/tipc/netlink.c
> +++ b/net/tipc/netlink.c
> @@ -54,7 +54,8 @@ static int handle_cmd(struct sk_buff *skb, struct genl_info *info)
>   	int hdr_space = nlmsg_total_size(GENL_HDRLEN + TIPC_GENL_HDRLEN);
>   	u16 cmd;
>
> -	if ((req_userhdr->cmd & 0xC000) && (!netlink_capable(skb, CAP_NET_ADMIN)))
> +	if ((req_userhdr->cmd & 0xC000) &&
> +	    (!netlink_net_capable(skb, CAP_NET_ADMIN)))

    Why? Also, it seems like unrelated change...

[...]

WBR, Sergei
