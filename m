From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH iproute2 net-next-for-3.13 1/2] iplink: display slave
 information
Date: Mon, 10 Feb 2014 17:34:34 +0400
Message-ID: <52F8D56A.2090704@cogentembedded.com>
References: <20140210081146.6F4FEE5697@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Michal Kubecek <mkubecek@suse.cz>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:47098 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752851AbaBJNeg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 08:34:36 -0500
Received: by mail-lb0-f182.google.com with SMTP id w7so4893204lbi.27
        for <netdev@vger.kernel.org>; Mon, 10 Feb 2014 05:34:35 -0800 (PST)
In-Reply-To: <20140210081146.6F4FEE5697@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10-02-2014 12:11, Michal Kubecek wrote:

> Add print_slave_opt() callback and maxslattr value to struct
> link_util. These are analogous to print_opt() and maxattr but
> relate to slave info (IFLA_INFO_SLAVE_{KIND,DATA}).

> Display the slave specific info in output of "ip -d link show".

> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
[...]

> diff --git a/ip/ipaddress.c b/ip/ipaddress.c
> index f794fa1..3cb7ee7 100644
> --- a/ip/ipaddress.c
> +++ b/ip/ipaddress.c
[...]
> @@ -221,6 +221,29 @@ static void print_linktype(FILE *fp, struct rtattr *tb)
>   		    lu->print_xstats)
>   			lu->print_xstats(lu, fp, linkinfo[IFLA_INFO_XSTATS]);
>   	}
> +
> +no_info:
> +	if (!linkinfo[IFLA_INFO_SLAVE_KIND])
> +		return;
> +	kind = RTA_DATA(linkinfo[IFLA_INFO_SLAVE_KIND]);
> +
> +	fprintf(fp, "%s", _SL_);
> +	fprintf(fp, "    %s_slave ", kind);
> +
> +	lu = get_link_kind(kind);
> +	if (!lu || !lu->print_slave_opt)
> +		return;
> +
> +	if (1) {

    Why is that?

> +		struct rtattr *attr[lu->maxslattr+1], **data = NULL;
> +
> +		if (linkinfo[IFLA_INFO_SLAVE_DATA]) {
> +			parse_rtattr_nested(attr, lu->maxslattr,
> +					    linkinfo[IFLA_INFO_SLAVE_DATA]);
> +			data = attr;
> +		}
> +		lu->print_slave_opt(lu, fp, data);
> +	}

WBR, Sergei
