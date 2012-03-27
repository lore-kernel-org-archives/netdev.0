From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: RCU lock bug in 3.0.21 (bisected to: 682cb56a, fix NULL
 dereferences in check_peer_redir)
Date: Mon, 26 Mar 2012 22:11:20 -0700
Message-ID: <20120327051120.GM2450@linux.vnet.ibm.com>
References: <4F70E308.7070908@candelatech.com>
 <20120326.174945.1186427809261872546.davem@davemloft.net>
 <4F70E560.3020102@candelatech.com>
 <4F70F688.6050108@candelatech.com>
 <1332805148.3547.14.camel@edumazet-glaptop>
 <4F70FFE0.7070204@candelatech.com>
 <1332806834.3547.16.camel@edumazet-glaptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	gregkh@linuxfoundation.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:47472 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753044Ab2C0FLa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 01:11:30 -0400
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 26 Mar 2012 23:11:30 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 4C4B919D804C
	for <netdev@vger.kernel.org>; Mon, 26 Mar 2012 23:11:20 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q2R5BR0n192604
	for <netdev@vger.kernel.org>; Mon, 26 Mar 2012 23:11:27 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q2R5BQmP014736
	for <netdev@vger.kernel.org>; Mon, 26 Mar 2012 23:11:27 -0600
Content-Disposition: inline
In-Reply-To: <1332806834.3547.16.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 27, 2012 at 02:07:14AM +0200, Eric Dumazet wrote:
> On Mon, 2012-03-26 at 16:46 -0700, Ben Greear wrote:
> 
> > The 3.0.21 kernel doesn't appear to have a rcu_read_lock_return(),
> > so I can't use your patch below.
> 
> This patch was only to show the point (I also CCed Paul, he might have
> some time to think about it, after he clears the inline stuff with
> Linus)

There is an rcu_preempt_depth() that returns rcu_read_lock() nesting
level for CONFIG_PREEMPT_RCU=y on the one hand and returns zero
for CONFIG_PREEMPT_RCU=n on the other.  So if you can reproduce
with CONFIG_PREEMPT_RCU=y, you can substitute rcu_preempt_depth()
rcu_read_lock_return() in Eric's earlier patch.

							Thanx, Paul

> As I said, I was referreing to you adding stuff in rcu. ;)
> 
> Unfortunately I wont have time in the near future to do so myself.
> 
> 
> 
