From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Moving frags and SKBTX_DEV_ZEROCOPY skbs
Date: Wed, 14 May 2014 10:52:23 -0700
Message-ID: <1400089943.7973.105.camel@edumazet-glaptop2.roam.corp.google.com>
References: <53737266.5040601@citrix.com>
	 <1400077432.7973.85.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140514.134247.1863750484757866783.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: zoltan.kiss@citrix.com, netdev@vger.kernel.org,
	xen-devel@lists.xenproject.org, kvm@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:59006 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750915AbaENRwY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 13:52:24 -0400
In-Reply-To: <20140514.134247.1863750484757866783.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-05-14 at 13:42 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 14 May 2014 07:23:52 -0700
> 
> > On Wed, 2014-05-14 at 14:40 +0100, Zoltan Kiss wrote:
> >> Hi,
> >> 
> >> Recently I've investigated issues around SKBTX_DEV_ZEROCOPY skbs where 
> >> the frags list were modified. I came across this function skb_shift(), 
> >> which moves frags between skbs. And there are a lot more of such kind, 
> >> skb_split or skb_try_coalesce, for example.
> >> It could be a dangerous thing if a frag is referenced from an skb which 
> >> doesn't have the original destructor_arg, and to avoid that 
> >> skb_orphan_frags should be called. Although probably these functions are 
> >> not normally touched in usual usecases, I think it would be useful to 
> >> review core skb functions proactively and add an skb_orphan_frags 
> >> everywhere where the frags could be referenced from other places.
> >> Any opinion about this?
> > 
> > 
> > For skb_shift(), it is currently used from tcp stack only, where
> > this SKBTX_DEV_ZEROCOPY thing is not used, so I do not think there is a
> > bug for the moment.
> > 
> > I already gave a patch for skb_try_coalesce() : For this one we do not
> > wan skb_orphan_frags() overhead. Its simply better in this case to
> > abort.
> 
> Eric can you please submit this formally?  It is second time I've seen
> it posted as RFC :-)

Sure, I was kind of waiting to make sure it was needed.

It looks like it is ;)
