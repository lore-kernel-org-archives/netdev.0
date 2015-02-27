From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: do not use rcu in rtnl_dump_ifinfo()
Date: Fri, 27 Feb 2015 09:40:30 -0800
Message-ID: <1425058830.5130.30.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425018776-14725-1-git-send-email-xiyou.wangcong@gmail.com>
	 <1425024069.5130.10.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54F09A95.8000507@6wind.com>
	 <1425056838.5130.27.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54F0A71F.3040808@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, David Miller <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:34075 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755128AbbB0Rkc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 12:40:32 -0500
Received: by igal13 with SMTP id l13so2022823iga.1
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 09:40:32 -0800 (PST)
In-Reply-To: <54F0A71F.3040808@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-02-27 at 18:19 +0100, Daniel Borkmann wrote:
> On 02/27/2015 06:07 PM, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >
> > We did a failed attempt in the past to only use rcu in rtnl dump
> > operations (commit e67f88dd12f6 "net: dont hold rtnl mutex during
> > netlink dump callbacks")
> >
> > Now that dumps are holding RTNL anyway, there is no need to also
> > use rcu locking, as it forbids any scheduling ability, like
> > GFP_KERNEL allocations that controlling path should use instead
> > of GFP_ATOMIC whenever possible.
> >
> > This should fix following splat Cong Wang reported :
> >
> > ===============================
> 
> [ Btw, I think patchwork has an issue with above line when fetching
>    the mbox : it thinks commit description ends here. :(
> 
>    Prefixing with a space char should help to not get it lost. ]


Thanks Daniel for this hint, will send a v2.
