From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 3/3] ipv6: Fix dst_entry refcnt bugs in ip6_tunnel
Date: Tue, 01 Sep 2015 14:26:58 -0700
Message-ID: <1441142818.8932.185.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1441133703-1570969-1-git-send-email-kafai@fb.com>
	 <1441133703-1570969-4-git-send-email-kafai@fb.com>
	 <1441138460.8932.182.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150901205505.GA66075@kafai-mba.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35635 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750829AbbIAV1A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 17:27:00 -0400
Received: by pacfv12 with SMTP id fv12so7985613pac.2
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 14:27:00 -0700 (PDT)
In-Reply-To: <20150901205505.GA66075@kafai-mba.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-09-01 at 13:55 -0700, Martin KaFai Lau wrote:
> On Tue, Sep 01, 2015 at 01:14:20PM -0700, Eric Dumazet wrote:
> > It should not be a problem. refcnt is taken when/if necessary (skb
> > queued on a qdisc for example)
> >
> > We have other uses of skb_dst_set_noref()
> >
> > Please describe the problem ?
> The current ip6_tnl_dst_get() does not take the dst refcnt.
> 
> If the dst is released after ip6_tnl_dst_get() and before
> skb_dst_set_noref(), would it cause an issue?

We are under rcu here, and a dst in a cache is protected by RCU by
definition.

skb_dst_set_noref() has following debugging clause, does it trigger for
you ?

WARN_ON(!rcu_read_lock_held() && !rcu_read_lock_bh_held());
