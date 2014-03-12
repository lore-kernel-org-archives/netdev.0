From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: ip6_append_data_mtu do not handle the mtu of the second fragment properly
Date: Wed, 12 Mar 2014 11:26:46 +0100
Message-ID: <20140312102646.GD29404@order.stressinduktion.org>
References: <1394512309-8823-1-git-send-email-lucien.xin@gmail.com> <20140311144906.GA29404@order.stressinduktion.org> <CADvbK_fS0rhPodczcZ52YN9D7NBY_TG+6xXvt-shvvz+e3qLnw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: network dev <netdev@vger.kernel.org>,
	Gao feng <gaofeng@cn.fujitsu.com>
To: lucien xin <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:58551 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753489AbaCLK0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 06:26:48 -0400
Content-Disposition: inline
In-Reply-To: <CADvbK_fS0rhPodczcZ52YN9D7NBY_TG+6xXvt-shvvz+e3qLnw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 12, 2014 at 10:40:50AM +0800, lucien xin wrote:
> but I cannot understand the top half of ip6_append_data() has the code
> to get mtu,
>                 if (rt->dst.flags & DST_XFRM_TUNNEL)
>                         mtu = np->pmtudisc >= IPV6_PMTUDISC_PROBE ?
>                               rt->dst.dev->mtu : dst_mtu(&rt->dst);
>                 else
>                         mtu = np->pmtudisc >= IPV6_PMTUDISC_PROBE ?
>                               rt->dst.dev->mtu : dst_mtu(rt->dst.path);
> 
>  why it need to calculate mtu again?  just "mtu=*mtu +
> rt->dst.header_len", isn't it sufficient?

It would be possible if we are absolutely sure if we don't call
ip6_append_data_mtu a second time, which I have not yet reviewed.

The line I proposed above may also suffer from this problem.

Maybe you already checked that?

Greetings,

  Hannes
