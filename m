From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net] ipv4: restore rt->fi for reference counting
Date: Sun, 07 May 2017 11:53:00 -0700
Message-ID: <1494183180.7796.50.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1493934857-6693-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andreyknvl@google.com, edumazet@google.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33470 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751166AbdEGVmi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 7 May 2017 17:42:38 -0400
Received: by mail-pf0-f194.google.com with SMTP id b23so7428601pfc.0
        for <netdev@vger.kernel.org>; Sun, 07 May 2017 14:42:38 -0700 (PDT)
In-Reply-To: <1493934857-6693-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-05-04 at 14:54 -0700, Cong Wang wrote:
> IPv4 dst could use fi->fib_metrics to store metrics but fib_info
> itself is refcnt'ed, so without taking a refcnt fi and
> fi->fib_metrics could be freed while dst metrics still points to
> it. This triggers use-after-free as reported by Andrey twice.
> 
> This patch reverts commit 2860583fe840 ("ipv4: Kill rt->fi") to
> restore this reference counting. It is a quick fix for -net and
> -stable, for -net-next, as Eric suggested, we can consider doing
> reference counting for metrics itself instead of relying on fib_info.
> 
> IPv6 is very different, it copies or steals the metrics from mx6_config
> in fib6_commit_metrics() so probably doesn't need a refcnt.
> 
> Decnet has already done the refcnt'ing, see dn_fib_semantic_match().
> 
> Fixes: 2860583fe840 ("ipv4: Kill rt->fi")
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Tested-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
