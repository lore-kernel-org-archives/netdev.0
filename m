From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net_sched: hold tcf_lock in netdevice notifier
Date: Thu, 17 Jul 2014 16:01:54 -0700 (PDT)
Message-ID: <20140717.160154.2300876035776395529.davem@davemloft.net>
References: <1405545931-13832-1-git-send-email-xiyou.wangcong@gmail.com>
	<1405545931-13832-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, cwang@twopensource.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41292 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753896AbaGQXBz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 19:01:55 -0400
In-Reply-To: <1405545931-13832-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed, 16 Jul 2014 14:25:31 -0700

> From: Cong Wang <cwang@twopensource.com>
> 
> We modify mirred action (m->tcfm_dev) in netdev event, we need to
> prevent on-going mirred actions from reading freed m->tcfm_dev.
> So we need to acquire this spin lock.
> 
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <cwang@twopensource.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

FWIW, from looking at the code, this lock is definitely necessary.

The fact that device destruction is deferred to rtnl_unlock() only
means the problem is harder to hit, rather than impossible.
