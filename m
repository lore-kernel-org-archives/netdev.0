From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] net_sched: move tcf_lock down after
 gen_replace_estimator()
Date: Wed, 14 Jun 2017 14:41:19 -0400 (EDT)
Message-ID: <20170614.144119.741403806288454976.davem@davemloft.net>
References: <1497386184-14960-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicholashuber@gmail.com,
        labbott@redhat.com, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52882 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751682AbdFNSlU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 14:41:20 -0400
In-Reply-To: <1497386184-14960-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 13 Jun 2017 13:36:24 -0700

> Laura reported a sleep-in-atomic kernel warning inside
> tcf_act_police_init() which calls gen_replace_estimator() with
> spinlock protection.
> 
> It is not necessary in this case, we already have RTNL lock here
> so it is enough to protect concurrent writers. For the reader,
> i.e. tcf_act_police(), it needs to make decision based on this
> rate estimator, in the worst case we drop more/less packets than
> necessary while changing the rate in parallel, it is still acceptable.
> 
> Reported-by: Laura Abbott <labbott@redhat.com>
> Reported-by: Nick Huber <nicholashuber@gmail.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thanks.
