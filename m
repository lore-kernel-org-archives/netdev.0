From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v3 3/3] igmp: convert RTNL lock to a spinlock
Date: Thu, 06 Jun 2013 10:50:18 +0800
Message-ID: <1370487018.31875.12.camel@cr0>
References: <1370485211-11498-1-git-send-email-amwang@redhat.com>
	 <1370485211-11498-3-git-send-email-amwang@redhat.com>
	 <1370486400.24311.316.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44813 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755721Ab3FFCu3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jun 2013 22:50:29 -0400
In-Reply-To: <1370486400.24311.316.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-05 at 19:40 -0700, Eric Dumazet wrote:
> On Thu, 2013-06-06 at 10:20 +0800, Cong Wang wrote:
> > From: Cong Wang <amwang@redhat.com>
> > 
> > It is not necessary to hold RTNL lock to protect mc_list,
> > at least IPv6 mcast is using a local spinlock, IPv4 can do
> > this too. This patch converts RTNL lock+RCU to spinlock+RCU.
> > 
> 
> Why are you doing this ? 

RTNL is becoming another big kernel lock, we should not hold it unless
we have to, right?

> 
> Really, holding a spinlock in this code instead of a mutex brings all
> kind of problems.
> 
> For example, you have to use GFP_ATOMIC allocations instead of
> GFP_KERNEL
> 
> Not counting the race/bug you added in ip_mc_join_group()
> 

Maybe I should replace the spinlock with a mutex?
