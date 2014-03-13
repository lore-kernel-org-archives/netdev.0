From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RCU PATCH 06/14] net: sched: fw use RCU
Date: Thu, 13 Mar 2014 14:15:09 -0700
Message-ID: <20140313211509.GP21124@linux.vnet.ibm.com>
References: <20140310170008.3011.73599.stgit@nitbit.x32>
 <20140310170546.3011.82918.stgit@nitbit.x32>
 <1394473279.3607.46.camel@edumazet-glaptop2.roam.corp.google.com>
 <53208E3F.5090401@gmail.com>
 <1394643673.21721.48.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140313202245.GK21124@linux.vnet.ibm.com>
 <1394744203.21721.53.camel@edumazet-glaptop2.roam.corp.google.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>,
	xiyou.wangcong@gmail.com, jhs@mojatatu.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:37507 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752254AbaCMVPO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2014 17:15:14 -0400
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 13 Mar 2014 15:15:14 -0600
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 9E8323E40026
	for <netdev@vger.kernel.org>; Thu, 13 Mar 2014 15:15:10 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp07029.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2DJCMYS11993358
	for <netdev@vger.kernel.org>; Thu, 13 Mar 2014 20:12:22 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s2DLIhdC027039
	for <netdev@vger.kernel.org>; Thu, 13 Mar 2014 15:18:43 -0600
Content-Disposition: inline
In-Reply-To: <1394744203.21721.53.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 13, 2014 at 01:56:43PM -0700, Eric Dumazet wrote:
> On Thu, 2014-03-13 at 13:22 -0700, Paul E. McKenney wrote:
> 
> > Hmmm...  You know, the offset that kfree uses is a byte offset.  I see
> > no reason why any of the rcu_head structures should be misaligned.  If
> > HTSIZE is too big by only a factor of four or smaller, would the following
> > (untested) patch to RCU be appropriate?
> > 
> > 							Thanx, Paul
> > 
> > ------------------------------------------------------------------------
> > 
> > rcu: Increase kfree_rcu() offset range
> > 
> > The kfree_rcu() function operates by placing an offset into the rcu_head
> > structure in place of the function pointer that is normally there.
> > This offset cannot exceed 4095, on the theory that no Linux kernel will
> > ever have executable code in page zero.  However, the rcu_head structure
> > contains a pair of function pointers, and should never be misaligned.
> > This commit therefore divides the offset by the size of a pointer when
> > being placed into the rcu_head structure, and multiplies it by this
> > same constant when pulling it out.
> > 
> > Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> 
> SGTM, thanks Paul.
> 
> Reviewed-by: Eric Dumazet <edumzzet@google.com>

Very good, thank you!

John, could you please give it a try with that rcu_head structure
moved to the end and let me know how it goes?

							Thanx, Paul
