From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [Patch net-next v4 1/2] net_sched: move the empty tp check from
 ->destroy() to ->delete()
Date: Thu, 20 Apr 2017 11:10:48 +0200
Message-ID: <58F87B18.7000008@iogearbox.net>
References: <1492636882-19571-1-git-send-email-xiyou.wangcong@gmail.com> <1492636882-19571-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roi Dayan <roid@mellanox.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44131 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938800AbdDTJKv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 05:10:51 -0400
In-Reply-To: <1492636882-19571-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/19/2017 11:21 PM, Cong Wang wrote:
> We could have a race condition where in ->classify() path we
> dereference tp->root and meanwhile a parallel ->destroy() makes it
> a NULL. Daniel cured this bug in commit d936377414fa
> ("net, sched: respect rcu grace period on cls destruction").
>
> This happens when ->destroy() is called for deleting a filter to
> check if we are the last one in tp, this tp is still linked and
> visible at that time. The root cause of this problem is the semantic
> of ->destroy(), it does two things (for non-force case):
>
> 1) check if tp is empty
> 2) if tp is empty we could really destroy it
>
> and its caller, if cares, needs to check its return value to see if it
> is really destroyed. Therefore we can't unlink tp unless we know it is
> empty.
>
> As suggested by Daniel, we could actually move the test logic to ->delete()
> so that we can safely unlink tp after ->delete() tells us the last one is
> just deleted and before ->destroy().
>
> Fixes: 1e052be69d04 ("net_sched: destroy proto tp when all filters are gone")
> Cc: Roi Dayan <roid@mellanox.com>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: John Fastabend <john.fastabend@gmail.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Thanks!
