From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/7] net: speedup netns create/delete time
Date: Tue, 19 Sep 2017 16:20:13 -0700
Message-ID: <1505863213.29839.79.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170918190733.26272-1-edumazet@google.com>
         <20170919.160244.1149642515939268316.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org, ebiederm@xmission.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:38093 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751619AbdISXUP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 19:20:15 -0400
Received: by mail-pg0-f66.google.com with SMTP id m30so609933pgn.5
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 16:20:15 -0700 (PDT)
In-Reply-To: <20170919.160244.1149642515939268316.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-09-19 at 16:02 -0700, David Miller wrote:
> From: Eric Dumazet <edumazet@google.com>
> Date: Mon, 18 Sep 2017 12:07:26 -0700
> 
> > When rate of netns creation/deletion is high enough,
> > we observe softlockups in cleanup_net() caused by huge list
> > of netns and way too many rcu_barrier() calls.
> > 
> > This patch series does some optimizations in kobject,
> > and add batching to tunnels so that netns dismantles are
> > less costly.
> > 
> > IPv6 addrlabels also get a per netns list, and tcp_metrics
> > also benefit from batch flushing.
> > 
> > This gives me one order of magnitude gain.
> > (~50 ms -> ~5 ms for one netns create/delete pair)
> 
> I like it.
> 
> Please address the feedback about using skb_put_data() and
> resubmit.

Sure, will also remove a spurious // comment I accidentally left in
patch 7/7.
