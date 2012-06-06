From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Possible deadlock in ipv6?
Date: Wed, 06 Jun 2012 17:53:39 +0200
Message-ID: <1338998019.26966.10.camel@edumazet-glaptop>
References: <4FCF6DF4.2090304@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vladimir Davydov <vdavydov@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:41196 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756533Ab2FFPxr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 11:53:47 -0400
Received: by eeit10 with SMTP id t10so2394941eei.19
        for <netdev@vger.kernel.org>; Wed, 06 Jun 2012 08:53:46 -0700 (PDT)
In-Reply-To: <4FCF6DF4.2090304@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-06 at 18:49 +0400, Vladimir Davydov wrote:
> I'm not familiar with the linux net subsystem, so I would appreciate if 
> someone could clarify if the following call chain is possible:
> 
> addrconf_ifdown() calls neigh_ifdown(nd_tbl) which locks nd_tbl.lock for 
> writing and calls
> 
>      pneigh_ifdown
>      pndisc_destructor
>      ipv6_dev_mc_dec
>      __ipv6_dev_mc_dec
>      igmp6_group_dropped
>      igmp6_leave_group
>      igmp6_send
>      icmp6_dst_alloc
>      ip6_neigh_lookup
>      neigh_create
> 
> and neigh_create() locks nd_tbl.lock for writing again resulting in a 
> deadlock.

It seems a deadlock is possible indeed, good catch !
