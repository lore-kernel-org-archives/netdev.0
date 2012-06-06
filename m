From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Possible deadlock in ipv6?
Date: Wed, 06 Jun 2012 19:02:28 +0200
Message-ID: <1339002148.26966.14.camel@edumazet-glaptop>
References: <4FCF6DF4.2090304@parallels.com>
	 <1338998019.26966.10.camel@edumazet-glaptop>
	 <1338998314.26966.12.camel@edumazet-glaptop>
	 <D0983DA9-2545-4007-8A69-31DDCB9B7CCF@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Vladimir Davydov <VDavydov@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:54593 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756406Ab2FFRCc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 13:02:32 -0400
Received: by eeit10 with SMTP id t10so2421936eei.19
        for <netdev@vger.kernel.org>; Wed, 06 Jun 2012 10:02:31 -0700 (PDT)
In-Reply-To: <D0983DA9-2545-4007-8A69-31DDCB9B7CCF@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-06 at 20:01 +0400, Vladimir Davydov wrote:
> On Jun 6, 2012, at 7:58 PM, Eric Dumazet wrote:
> 
> > On Wed, 2012-06-06 at 17:53 +0200, Eric Dumazet wrote:
> >> On Wed, 2012-06-06 at 18:49 +0400, Vladimir Davydov wrote:
> >>> I'm not familiar with the linux net subsystem, so I would appreciate if 
> >>> someone could clarify if the following call chain is possible:
> >>> 
> >>> addrconf_ifdown() calls neigh_ifdown(nd_tbl) which locks nd_tbl.lock for 
> >>> writing and calls
> >>> 
> >>>     pneigh_ifdown
> >>>     pndisc_destructor
> >>>     ipv6_dev_mc_dec
> >>>     __ipv6_dev_mc_dec
> >>>     igmp6_group_dropped
> >>>     igmp6_leave_group
> >>>     igmp6_send
> >>>     icmp6_dst_alloc
> >>>     ip6_neigh_lookup
> >>>     neigh_create
> >>> 
> >>> and neigh_create() locks nd_tbl.lock for writing again resulting in a 
> >>> deadlock.
> >> 
> >> It seems a deadlock is possible indeed, good catch !
> >> 
> >> 
> > 
> > And it seems this neigh_down() can be removed, its called later
> > (after dev->ip6_ptr is cleared)
> > 
> 
> BTW, commit d1ed113f1669390da9898da3beddcc058d938587 did exactly the same, but it was reverted along with a bundle of other commits by 73a8bd74e2618990dbb218c3d82f53e60acd9af0.

Yes, but the revert was a 'revert a serie', while this particular patch
seems fine, especially if fixing a deadlock ;)
