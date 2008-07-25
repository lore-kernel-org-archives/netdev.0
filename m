From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH] Variables only used in ifdef
Date: Fri, 25 Jul 2008 11:15:06 +0800
Message-ID: <4889453A.8070002@cn.fujitsu.com>
References: <486DDE92.2010900@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: NETDEV <netdev@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50081 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751243AbYGYDQt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2008 23:16:49 -0400
In-Reply-To: <486DDE92.2010900@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen said the following on 2008-7-4 16:25:
> Move the variables which only used in #ifdef to where they should be.
> Otherwise, "defined but not used" compile warning will go out.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> ---
> diff --git a/drivers/net/wan/syncppp.c b/drivers/net/wan/syncppp.c
> index 29b4b94..c938d4c 100644
> --- a/drivers/net/wan/syncppp.c
> +++ b/drivers/net/wan/syncppp.c
> @@ -763,10 +763,10 @@ static void sppp_cisco_input (struct sppp *sp, struct sk_buff *skb)
>  	case CISCO_ADDR_REQ:
>  		/* Stolen from net/ipv4/devinet.c -- SIOCGIFADDR ioctl */
>  		{
> -		struct in_device *in_dev;
> -		struct in_ifaddr *ifa;
>  		__be32 addr = 0, mask = htonl(~0U); /* FIXME: is the mask correct? */
>  #ifdef CONFIG_INET
> +		struct in_device *in_dev;
> +		struct in_ifaddr *ifa;
>  		rcu_read_lock();
>  		if ((in_dev = __in_dev_get_rcu(dev)) != NULL)
>  		{
> 

Jeff, will you take this?

