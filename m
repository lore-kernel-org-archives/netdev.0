From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH net 1/2] ipv6: add missing netconf notif when 'all' is
 updated
Date: Tue, 30 Aug 2016 11:51:29 +0900
Message-ID: <21983bb4-de14-6811-865d-12f114f573b0@miraclelinux.com>
References: <1472465149-1163-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36231 "EHLO
        mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754321AbcH3Cvd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 22:51:33 -0400
Received: by mail-pa0-f53.google.com with SMTP id ci2so2400653pad.3
        for <netdev@vger.kernel.org>; Mon, 29 Aug 2016 19:51:32 -0700 (PDT)
In-Reply-To: <1472465149-1163-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Nicolas Dichtel wrote:
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

dflt, not dftl?

> +
>  		net->ipv6.devconf_dflt->forwarding = newf;
> +		if ((!newf) ^ (!old_dftl))
> +			inet6_netconf_notify_devconf(net, NETCONFA_FORWARDING,
> +						     NETCONFA_IFINDEX_DEFAULT,
> +						     net->ipv6.devconf_dflt);
> +
>  		addrconf_forward_change(net, newf);
>  		if ((!newf) ^ (!old))
>  			inet6_netconf_notify_devconf(net, NETCONFA_FORWARDING,
> 

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
