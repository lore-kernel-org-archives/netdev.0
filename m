From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] netns: Don't receive new packets in a dead network
	namespace.
Date: Sat, 21 Jun 2008 04:51:25 +0400
Message-ID: <20080621005125.GA5711@martell.zuzino.mipt.ru>
References: <20080620204943.GA5068@martell.zuzino.mipt.ru> <m1k5gjej5q.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	den@openvz.org, xemul@openvz.org, dlezcano@fr.ibm.com,
	benjamin.thery@bull.net
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:39517 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750833AbYFUAzd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2008 20:55:33 -0400
Received: by ug-out-1314.google.com with SMTP id h2so94959ugf.16
        for <netdev@vger.kernel.org>; Fri, 20 Jun 2008 17:55:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <m1k5gjej5q.fsf@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 20, 2008 at 05:17:05PM -0700, Eric W. Biederman wrote:
> --- a/include/net/net_namespace.h
> +++ b/include/net/net_namespace.h
> @@ -95,6 +95,11 @@ extern struct list_head net_namespace_list;
>  #ifdef CONFIG_NET_NS
>  extern void __put_net(struct net *net);
>  
> +static inline int net_alive(struct net *net)
> +{
> +	return net && atomic_read(&net->count);
> +}

netns pointers are always valid, right?

