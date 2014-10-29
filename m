From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net 2/2] net_sched: always call ->destroy when ->init()
 fails
Date: Wed, 29 Oct 2014 14:29:34 -0400 (EDT)
Message-ID: <20141029.142934.1722309776700951536.davem@davemloft.net>
References: <1414194959-28006-1-git-send-email-xiyou.wangcong@gmail.com>
	<1414194959-28006-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wang.bo116@zte.com.cn,
	john.r.fastabend@intel.com, edumazet@google.com, kaber@trash.net,
	vtlam@google.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45241 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750709AbaJ2S3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 14:29:36 -0400
In-Reply-To: <1414194959-28006-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri, 24 Oct 2014 16:55:59 -0700

> In qdisc_create(), when ->init() exists and it fails, we should
> call ->destroy() to clean up the potentially partially initialized
> qdisc's. This will also make the ->init() implementation easier.
> 
> qdisc_create_dflt() already does that. Most callers of qdisc_create_dflt()
> simply use noop_qdisc when it fails.
> 
> And, most of the ->destroy() implementations are already able to clean up
> partially initialization, we don't need to worry.
> 
> The following ->init()'s need to catch up:
> fq_codel_init(), hhf_init(), multiq_init(),  sfq_init(), mq_init(),
> mqprio_init().
> 
> Reported-by: Wang Bo <wang.bo116@zte.com.cn>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

As discussed, I really want to see ->init() clean up it's own crap.

There are certain kinds of initializations that cannot be tested for,
such as setting up a workqueue etc.

Therefore, the mere idea that we can call ->destroy() to handle this
is a pure non-starter as far as I am concerned.

Thanks.
