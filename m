From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH 1/8 net-2.6.26] [NETNS]: Make netns refconting debug like
 a socket one.
Date: Tue, 15 Apr 2008 10:55:20 -0400
Message-ID: <4804C1D8.7000803@hp.com>
References: <1208262959.21529.32.camel@iris.sw.ru> <1208263075-28016-1-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	containers@lists.osdl.org, dlezcano@fr.ibm.com
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:4183 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760111AbYDOOxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 10:53:31 -0400
In-Reply-To: <1208263075-28016-1-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denis V. Lunev wrote:
> +#ifdef NETNS_REFCNT_DEBUG
>  static inline struct net *hold_net(struct net *net)
>  {
> +	if (net == NULL)
> +		return NULL;
> +	atomic_inc(&net->use_count);
>  	return net;
>  }

This could be shrunk to:

	if (net)
		atomic_inc(&net->use_count);
	return net;

>  static inline void release_net(struct net *net)
>  {
> +	if (net == NULL)
> +		return;
> +	atomic_dec(&net->use_count);
>  }

This one too:

	if (net)
		atomic_dec(&net->use_count);

-Brian
