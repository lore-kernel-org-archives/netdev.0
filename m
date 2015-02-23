From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH net-next v3 2/2] multicast: Extend ip address command
 to enable multicast group join/leave on IP level.
Date: Mon, 23 Feb 2015 16:44:09 +0900
Message-ID: <54EADA49.6020308@miraclelinux.com>
References: <1424672814-2998-1-git-send-email-challa@noironetworks.com> <1424672814-2998-3-git-send-email-challa@noironetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, davem@davemloft.net,
	hideaki.yoshifuji@miraclelinux.com
To: Madhu Challa <challa@noironetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og101.obsmtp.com ([64.18.2.155]:37274 "HELO
	exprod7og101.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751174AbbBWHwS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 02:52:18 -0500
Received: by mail-pa0-f42.google.com with SMTP id et14so25502582pad.11
        for <netdev@vger.kernel.org>; Sun, 22 Feb 2015 23:52:17 -0800 (PST)
In-Reply-To: <1424672814-2998-3-git-send-email-challa@noironetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Madhu Challa wrote:

> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> index 3a8985c..ee56730 100644
> --- a/net/ipv4/devinet.c
> +++ b/net/ipv4/devinet.c

> @@ -838,6 +864,16 @@ static int inet_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
>   		 * userspace already relies on not having to provide this.
>   		 */
>   		set_ifa_lifetime(ifa, valid_lft, prefered_lft);
> +		if (ifa->ifa_flags & IFA_F_MCAUTOJOIN) {
> +			WARN_ON(!ipv4_is_multicast(ifa->ifa_address));
> +			ret = ip_mc_config(net->ipv4.mc_autojoin_sock,
> +					   true, ifa->ifa_address,
> +					   ifa->ifa_dev->dev->ifindex);
> +			if (ret < 0) {
> +				inet_free_ifa(ifa);
> +				return ret;
> +			}
> +		}

No WARN_ON() here, please.


> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 98e4a63..b9b6d52 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -2501,6 +2519,14 @@ static int inet6_addr_add(struct net *net, int ifindex,
>   	if (IS_ERR(idev))
>   		return PTR_ERR(idev);
>   
> +	if (ifa_flags & IFA_F_MCAUTOJOIN) {
> +		WARN_ON(!ipv6_addr_is_multicast(pfx));
> +		ret = ipv6_mc_config(net->ipv6.mc_autojoin_sock,
> +				     true, pfx, ifindex);
> +		if (ret < 0)
> +			return ret;
> +	}
> +
>   	scope = ipv6_addr_scope(pfx);
>   
>   	timeout = addrconf_timeout_fixup(valid_lft, HZ);

ditto.

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
