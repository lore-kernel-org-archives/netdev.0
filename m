From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] neighbour: always have struct net pointer in
 struct neigh_parms
Date: Tue, 10 Dec 2013 20:48:50 +0100
Message-ID: <20131210194850.GE2469@minipsycho.orion>
References: <1386661497-1688-1-git-send-email-jiri@resnulli.us>
 <20131210.144538.1753921871836942715.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f42.google.com ([74.125.83.42]:60761 "EHLO
	mail-ee0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750706Ab3LJTsy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 14:48:54 -0500
Received: by mail-ee0-f42.google.com with SMTP id e53so2477754eek.1
        for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 11:48:53 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131210.144538.1753921871836942715.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Dec 10, 2013 at 08:45:38PM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Tue, 10 Dec 2013 08:44:57 +0100
>
>> This fixes compile error when CONFIG_NET_NS is not set.
>> 
>> Introduced by:
>> commit 1d4c8c29841b9991cdf3c7cc4ba7f96a94f104ca
>>     "neigh: restore old behaviour of default parms values"
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>
>Jiri please don't fix things this way.
>
>When network name spaces are disabled, you're supposed to abstract
>all of this stuff away behind accessor macros so that it is truly
>zero cost.
>
>For example, look at how "dev_net()" and related helpers works.
>
>This means you need to do something like:
>
>/*
> * Net namespace inlines
> */
>static inline
>struct net *neigh_parms_net(const struct neigh_parms *np)
>{
>	return read_pnet(&np->net);
>}
>
>static inline
>void neigh_parms_net_set(struct neigh_parms *np, struct net *net)
>{
>#ifdef CONFIG_NET_NS
>	release_net(np->net);
>	np->net = hold_net(net);
>#endif
>}
>
>And then use these helpers consistently in your new code.

Will do. Thanks.

>
>Thanks.
