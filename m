From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RCU PATCH 06/14] net: sched: fw use RCU
Date: Thu, 13 Mar 2014 13:56:43 -0700
Message-ID: <1394744203.21721.53.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140310170008.3011.73599.stgit@nitbit.x32>
	 <20140310170546.3011.82918.stgit@nitbit.x32>
	 <1394473279.3607.46.camel@edumazet-glaptop2.roam.corp.google.com>
	 <53208E3F.5090401@gmail.com>
	 <1394643673.21721.48.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140313202245.GK21124@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
	xiyou.wangcong@gmail.com, jhs@mojatatu.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:63135 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755101AbaCMU4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2014 16:56:45 -0400
Received: by mail-pb0-f46.google.com with SMTP id rq2so1647351pbb.33
        for <netdev@vger.kernel.org>; Thu, 13 Mar 2014 13:56:45 -0700 (PDT)
In-Reply-To: <20140313202245.GK21124@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-03-13 at 13:22 -0700, Paul E. McKenney wrote:

> Hmmm...  You know, the offset that kfree uses is a byte offset.  I see
> no reason why any of the rcu_head structures should be misaligned.  If
> HTSIZE is too big by only a factor of four or smaller, would the following
> (untested) patch to RCU be appropriate?
> 
> 							Thanx, Paul
> 
> ------------------------------------------------------------------------
> 
> rcu: Increase kfree_rcu() offset range
> 
> The kfree_rcu() function operates by placing an offset into the rcu_head
> structure in place of the function pointer that is normally there.
> This offset cannot exceed 4095, on the theory that no Linux kernel will
> ever have executable code in page zero.  However, the rcu_head structure
> contains a pair of function pointers, and should never be misaligned.
> This commit therefore divides the offset by the size of a pointer when
> being placed into the rcu_head structure, and multiplies it by this
> same constant when pulling it out.
> 
> Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

SGTM, thanks Paul.

Reviewed-by: Eric Dumazet <edumzzet@google.com>
