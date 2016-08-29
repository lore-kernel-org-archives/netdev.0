From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net 1/2] ipv6: add missing netconf notif when 'all' is
 updated
Date: Mon, 29 Aug 2016 16:00:38 +0300
Message-ID: <705293f5-0965-8d1c-1539-b70cbed6aea9@cogentembedded.com>
References: <1472465149-1163-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:34580 "EHLO
        mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932750AbcH2NHY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 09:07:24 -0400
Received: by mail-lf0-f48.google.com with SMTP id l89so100386419lfi.1
        for <netdev@vger.kernel.org>; Mon, 29 Aug 2016 06:07:23 -0700 (PDT)
In-Reply-To: <1472465149-1163-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 8/29/2016 1:05 PM, Nicolas Dichtel wrote:

> The 'default' value was not advertised.
>
> Fixes: f3a1bfb11ccb ("rtnl/ipv6: use netconf msg to advertise forwarding status")
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  net/ipv6/addrconf.c | 7 +++++++
>  1 file changed, 7 insertions(+)
>
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index f418d2eaeddd..299f0656e87f 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -778,7 +778,14 @@ static int addrconf_fixup_forwarding(struct ctl_table *table, int *p, int newf)
>  	}
>
>  	if (p == &net->ipv6.devconf_all->forwarding) {
> +		int old_dftl = net->ipv6.devconf_dflt->forwarding;
> +
>  		net->ipv6.devconf_dflt->forwarding = newf;
> +		if ((!newf) ^ (!old_dftl))

    IIUC, !'s are not necessary here (and more so the parens around them). And 
perhaps ^ can be changed to != for clarity...

> +			inet6_netconf_notify_devconf(net, NETCONFA_FORWARDING,
> +						     NETCONFA_IFINDEX_DEFAULT,
> +						     net->ipv6.devconf_dflt);
> +
>  		addrconf_forward_change(net, newf);
>  		if ((!newf) ^ (!old))
>  			inet6_netconf_notify_devconf(net, NETCONFA_FORWARDING,

MBR, Sergei
