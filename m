From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6 v2] pkt_sched: gen_estimator: kill
	est_lock rwlock
Date: Tue, 8 Jun 2010 12:15:46 +0000
Message-ID: <20100608121546.GA9392@ff.dom.local>
References: <1275929761.2545.159.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:59406 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753388Ab0FHMPv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 08:15:51 -0400
Received: by fxm8 with SMTP id 8so2822457fxm.19
        for <netdev@vger.kernel.org>; Tue, 08 Jun 2010 05:15:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1275929761.2545.159.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
...
> [PATCH net-next-2.6] pkt_sched: gen_kill_estimator() rcu fixes
> 
> gen_kill_estimator() API is fundamentaly wrong, since caller should make
> sure an RCU grace period is respected before freeing bstats or lock.
> 
> This was partially addressed in commit 5d944c640b4 (gen_estimator:
> deadlock fix), but same problem exist for all gen_kill_estimator()
> users.
> 
> Change its name to gen_kill_estimator_rcu() and change all callers to
> use RCU grace period before freeing bstats container.
> 
> As a bonus, est_lock rwlock can be killed for good.
> 
> Special thanks to Changli Gao for commenting on a previous patch, this
> made this bug clear to me.
> 

Actually, I guess, Changli meant the bug introduced by your previous
patch by removing the est_lock. With this lock (and your commit 5d944)
bstats (and API) seem "fundamentaly" safe.

Jarek P.
