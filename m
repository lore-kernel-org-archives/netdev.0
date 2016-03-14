From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [net-next,iproute2] netconf: add support for ignore route
 attribute
Date: Sun, 13 Mar 2016 23:15:38 -0700
Message-ID: <20160313231538.48e341dd@xeon-e3>
References: <1457931336-30205-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35257 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752122AbcCNGPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 02:15:24 -0400
Received: by mail-pa0-f50.google.com with SMTP id td3so122620828pab.2
        for <netdev@vger.kernel.org>; Sun, 13 Mar 2016 23:15:24 -0700 (PDT)
In-Reply-To: <1457931336-30205-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 14 Mar 2016 04:55:36 +0000
Zhang Shengju <zhangshengju@cmss.chinamobile.com> wrote:

> Add support for ignore_routes_with_linkdown attribute.
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> ---
>  ip/ipnetconf.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/ip/ipnetconf.c b/ip/ipnetconf.c
> index eca6eee..6fec818 100644
> --- a/ip/ipnetconf.c
> +++ b/ip/ipnetconf.c
> @@ -119,6 +119,10 @@ int print_netconf(const struct sockaddr_nl *who, struct rtnl_ctrl_data *ctrl,
>  		fprintf(fp, "proxy_neigh %s ",
>  			*(int *)RTA_DATA(tb[NETCONFA_PROXY_NEIGH])?"on":"off");
>  
> +	if (tb[NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN])
> +		fprintf(fp, "ignore_routes_with_linkdown %s ",
> +			*(int *)RTA_DATA(tb[NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN])?"on":"off");

This is a good idea.

But the option name is too long, and the code does not follow current best practices.
  1. Lines are too long
  2. There needs to be whitespace around ? :
  3. There are helper routines (rte_getattr_XXX) which should be used rather than
     cast RTE_DATA directly.

Also, help and man page??
