From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next 4/5] net_sched: forbid setting default qdisc
 to inappropriate ones
Date: Thu, 27 Aug 2015 15:30:46 -0700 (PDT)
Message-ID: <20150827.153046.2021133935222197667.davem@davemloft.net>
References: <1440628887-3504-1-git-send-email-xiyou.wangcong@gmail.com>
	<1440628887-3504-5-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
	stephen@networkplumber.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47709 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753682AbbH0Wau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 18:30:50 -0400
In-Reply-To: <1440628887-3504-5-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed, 26 Aug 2015 15:41:26 -0700

> Currently there is no check for if a qdisc is appropriate
> to be used as the default qdisc. This causes we get no
> error even we set the default qdisc to an inappropriate one
> but an error will be shown up later. This is not good.
> 
> Also, for qdisc's like HTB, kernel will just crash when
> we use it as default qdisc, because some data structures are
> not even initialized yet before checking opt == NULL, the cleanup
> doing ->reset() or ->destroy() on them will just crash.
> 
> Let's fail as early as we can.
> 
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

I don't like this.

The situation is that some sophisticated qdiscs can function without
explicit parameters, some cannot.

That is the problem you need to solve.  For example, if "opts" is NULL
HTB should use a reasonable set of defaults instead of failing.

Furthermore, you can improve the behavior when this happens.

When qdisc_create_dflt() returns NULL because ops->init() fails, do
something reasonable.

I'm not applying this patch series, it papers over the issue rather
than actually addressing it properly.
