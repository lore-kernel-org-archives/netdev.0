From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 2/2] ipv6:  Allow accepting RA from local IP addresses.
Date: Fri, 20 Jun 2014 17:40:36 +0200
Message-ID: <1403278836.22173.21.camel@localhost>
References: <1403113806-13004-1-git-send-email-greearb@candelatech.com>
	 <1403113806-13004-2-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:51033 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932228AbaFTPlu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 11:41:50 -0400
Received: from compute5.internal (compute5.nyi.mail.srv.osa [10.202.2.45])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 630E720E56
	for <netdev@vger.kernel.org>; Fri, 20 Jun 2014 11:41:45 -0400 (EDT)
In-Reply-To: <1403113806-13004-2-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mi, 2014-06-18 at 10:50 -0700, greearb@candelatech.com wrote:
> From: Ben Greear <greearb@candelatech.com>
> 
> This can be used in virtual networking applications, and
> may have other uses as well.  The option is disabled by
> default, so no change to current operating behaviour
> without the user explicitly changing the behaviour.

Can you give a specific example for its use case? I currently don't see
the need for such an option.

 
> -	if (ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr,
> +	if (!(in6_dev->cnf.accept_ra_from_local ||
> +	      dev_net(in6_dev->dev)->ipv6.devconf_all->accept_ra_from_local) &&
> +	    ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr,
>  			  NULL, 0)) {
>  		ND_PRINTK(2, info,
>  			  "RA: %s, chk_addr failed for dev: %s\n",
> @@ -1293,7 +1295,9 @@ skip_linkparms:
>  	}
>  
>  #ifdef CONFIG_IPV6_ROUTE_INFO
> -	if (ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr,
> +	if (!(in6_dev->cnf.accept_ra_from_local ||
> +	      dev_net(in6_dev->dev)->ipv6.devconf_all->accept_ra_from_local) &&
> +	    ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr,
>  			  NULL, 0)) {
>  		ND_PRINTK(2, info,
>  			  "RA: %s, chk-addr (route info) is false for dev: %s\n",

Maybe ipv6_accept_ra_local() like ipv6_accept_ra() static local to the
file?

Also I am not sure if we want to provide an devconf_all for this setting
at all, like we don't evaluate it for accept_ra, too. At least I
wouldn't do so with the current state of ipv6/conf/{all,default}.

Bye,
Hannes
