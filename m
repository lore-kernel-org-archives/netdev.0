From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] net_sched: reorder pernet ops and act ops
 registrations
Date: Thu, 13 Oct 2016 10:27:18 -0400 (EDT)
Message-ID: <20161013.102718.1511430978252015336.davem@davemloft.net>
References: <1476208605-16199-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kjlx@templeofstupid.com, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33662 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751510AbcJMOxt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 10:53:49 -0400
In-Reply-To: <1476208605-16199-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 11 Oct 2016 10:56:45 -0700

> Krister reported a kernel NULL pointer dereference after
> tcf_action_init_1() invokes a_o->init(), it is a race condition
> where one thread calling tcf_register_action() to initialize
> the netns data after putting act ops in the global list and
> the other thread searching the list and then calling
> a_o->init(net, ...).
> 
> Fix this by moving the pernet ops registration before making
> the action ops visible. This is fine because: a) we don't
> rely on act_base in pernet ops->init(), b) in the worst case we
> have a fully initialized netns but ops is still not ready so
> new actions still can't be created.
> 
> Reported-by: Krister Johansen <kjlx@templeofstupid.com>
> Tested-by: Krister Johansen <kjlx@templeofstupid.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied and queued up for -stable, thanks.
