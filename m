From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] act_mirred: fix a race condition on mirred_list
Date: Mon, 05 Oct 2015 06:31:12 -0700 (PDT)
Message-ID: <20151005.063112.2276279050001307569.davem@davemloft.net>
References: <1443724663-27158-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com, jhs@mojatatu.com,
	cwang@twopensource.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39938 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751965AbbJENPe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 09:15:34 -0400
In-Reply-To: <1443724663-27158-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Thu,  1 Oct 2015 11:37:42 -0700

> After commit 1ce87720d456 ("net: sched: make cls_u32 lockless")
> we began to release tc actions in a RCU callback. However,
> mirred action relies on RTNL lock to protect the global
> mirred_list, therefore we could have a race condition
> between RCU callback and netdevice event, which caused
> a list corruption as reported by Vinson.
> 
> Instead of relying on RTNL lock, introduce a spinlock to
> protect this list.
> 
> Note, in non-bind case, it is still called with RTNL lock,
> therefore should disable BH too.
> 
> Reported-by: Vinson Lee <vlee@twopensource.com>
> Cc: John Fastabend <john.fastabend@gmail.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <cwang@twopensource.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
