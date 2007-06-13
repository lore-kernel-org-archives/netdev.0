From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Virtual ethernet tunnel
Date: Wed, 13 Jun 2007 17:37:20 +0200
Message-ID: <46700F30.7060808@trash.net>
References: <4666CEAA.8010903@openvz.org> <4666D296.2000002@trash.net> <4667BD1D.9080905@openvz.org> <466D3466.10306@trash.net> <466FB7E7.4060201@openvz.org> <466FD113.3070909@trash.net> <4670150E.5010309@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>,
	Kirill Korotaev <dev@openvz.org>
To: Pavel Emelianov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34221 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758035AbXFMPhY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 11:37:24 -0400
In-Reply-To: <4670150E.5010309@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelianov wrote:
> Patrick McHardy wrote:
> 
>>I'm going to push my latest patches to Dave today, the easiest way is
>>probably is you just add whatever you need to the API afterwards.
>>
> 
> 
> OK. Dave didn't object against the driver. Hope he will accept it as well.
> 
> I have also found a BUG in your API. Look, when you declare the alias with
> the MODULE_ALIAS_RTNL_LINK in drivers you use strings as an argument. But 
> this macro stringifyes the argument itself which results in bad aliases.
> 
> Signed-off-by: Pavel Emelianov <xemul@openvz.org>
> 
> ---
> 
> diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
> index d744198..f627e1f 100644
> --- a/include/net/rtnetlink.h
> +++ b/include/net/rtnetlink.h
> @@ -77,6 +77,6 @@ extern void	__rtnl_link_unregister(struc
>  extern int	rtnl_link_register(struct rtnl_link_ops *ops);
>  extern void	rtnl_link_unregister(struct rtnl_link_ops *ops);
>  
> -#define MODULE_ALIAS_RTNL_LINK(name) MODULE_ALIAS("rtnl-link-" #name)
> +#define MODULE_ALIAS_RTNL_LINK(name) MODULE_ALIAS("rtnl-link-" name)


Thanks, I already fixed this during final round of testing :)
