From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v5 3/3] igmp: convert RTNL lock to a spinlock
Date: Sat, 15 Jun 2013 16:44:37 +0800
Message-ID: <1371285877.23997.14.camel@cr0>
References: <1371282069-26893-1-git-send-email-amwang@redhat.com>
	 <1371282069-26893-3-git-send-email-amwang@redhat.com>
	 <1371282946.3252.148.camel@edumazet-glaptop> <1371283942.23997.8.camel@cr0>
	 <1371284768.3252.151.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48262 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752315Ab3FOIos (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Jun 2013 04:44:48 -0400
In-Reply-To: <1371284768.3252.151.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-06-15 at 01:26 -0700, Eric Dumazet wrote:
> On Sat, 2013-06-15 at 16:12 +0800, Cong Wang wrote:
> 
> > I _did_ try to replace spinlock with mutex, but apparently mutex_lock()
> > can't be called with rcu_read_lock() held, which is the case in
> > ip_mc_drop_socket().
> > 
> 
> If you hold a mutex, there is no need for rcu_read_lock() at all.
> 
> Nobody can change the lists while you are the owner.
> 
> We already have nice helpers, lockdep enabled.
> 
> check rtnl_dereference() uses
> 
> 

Oops, I should mean to say ip_mc_leave_group(), not
ip_mc_drop_socket()...

The reason why it holds RCU is to get in_dev and still uses it after
spinlock is held, but I think we can fix ip_mc_find_dev() so that we can
call it without holding RCU outside, by taking a ref to in_dev?

Thanks!
