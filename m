From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm/svc: Fix blocking in wait loop
Date: Tue, 12 Aug 2014 15:02:25 -0700 (PDT)
Message-ID: <20140812.150225.33325749199708788.davem@davemloft.net>
References: <20140807172514.GY9918@twins.programming.kicks-ass.net>
	<20140807172901.GH3588@twins.programming.kicks-ass.net>
	<20140812081226.0fb0534e@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peterz@infradead.org, fengguang.wu@intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org, lkp@01.org,
	linux-atm-general@lists.sourceforge.net
To: chas@cmf.nrl.navy.mil
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140812081226.0fb0534e@thirdoffive.cmf.nrl.navy.mil>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Date: Tue, 12 Aug 2014 08:12:26 -0400

> One should not call blocking primitives inside a wait loop, since both
> require task_struct::state to sleep, so the inner will destroy the
> outer state.
> 
> sigd_enq() will possibly sleep for alloc_skb().  Move sigd_enq() before
> prepare_to_wait() to avoid sleeping while waiting interruptibly.  You do
> not actually need to call sigd_enq() after the initial prepare_to_wait()
> because we test the termination condition before calling schedule().
> 
> Based on suggestions from Peter Zijlstra.
> 
> Signed-off-by: Chas Williams <chas@cmf.n4rl.navy.mil>
> Acked-by: Peter Zijlstra <peterz@infradead.org>

Applied.
