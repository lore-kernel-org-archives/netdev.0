From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net-next v5 3/3] igmp: convert RTNL lock to a spinlock
Date: Sat, 15 Jun 2013 00:55:46 -0700
Message-ID: <1371282946.3252.148.camel@edumazet-glaptop>
References: <1371282069-26893-1-git-send-email-amwang@redhat.com>
	 <1371282069-26893-3-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f172.google.com ([209.85.215.172]:50018 "EHLO
	mail-ea0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754092Ab3FOHzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Jun 2013 03:55:50 -0400
Received: by mail-ea0-f172.google.com with SMTP id q10so784673eaj.31
        for <netdev@vger.kernel.org>; Sat, 15 Jun 2013 00:55:49 -0700 (PDT)
In-Reply-To: <1371282069-26893-3-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-06-15 at 15:41 +0800, Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
> 
> It is not necessary to hold RTNL lock to protect mc_list,
> at least IPv6 mcast is using a local spinlock, IPv4 can do
> this too. This patch converts RTNL lock+RCU to spinlock+RCU.
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> ---
> v5: no change
> v4: rebased on the latest net-next.
> v3: remove useless synchronize_rcu().

Really I think this patch is not needed and way too risky.

I already said that you added bugs, and you keep posting same bugs ?

ip_mc_join_group() seems buggy after your v5 patch ?

Let me repeat : fast path already uses RCU.

The writer parts are slow path, using a mutex is much better than a
spinlock as a mutex allows the writer to use GFP_KERNEL allocations, and
eventually be preempted/scheduled.

Just leave this code as is, this is a waste of time.
