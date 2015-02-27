From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] net: do not use rcu in rtnl_dump_ifinfo()
Date: Fri, 27 Feb 2015 18:19:27 +0100
Message-ID: <54F0A71F.3040808@iogearbox.net>
References: <1425018776-14725-1-git-send-email-xiyou.wangcong@gmail.com>	 <1425024069.5130.10.camel@edumazet-glaptop2.roam.corp.google.com>	 <54F09A95.8000507@6wind.com> <1425056838.5130.27.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>, nicolas.dichtel@6wind.com,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59144 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752069AbbB0RTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 12:19:32 -0500
In-Reply-To: <1425056838.5130.27.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/27/2015 06:07 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> We did a failed attempt in the past to only use rcu in rtnl dump
> operations (commit e67f88dd12f6 "net: dont hold rtnl mutex during
> netlink dump callbacks")
>
> Now that dumps are holding RTNL anyway, there is no need to also
> use rcu locking, as it forbids any scheduling ability, like
> GFP_KERNEL allocations that controlling path should use instead
> of GFP_ATOMIC whenever possible.
>
> This should fix following splat Cong Wang reported :
>
> ===============================

[ Btw, I think patchwork has an issue with above line when fetching
   the mbox : it thinks commit description ends here. :(

   Prefixing with a space char should help to not get it lost. ]
