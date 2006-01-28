From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 3/4] net: Percpufy frequently used variables --
 proto.sockets_allocated
Date: Fri, 27 Jan 2006 16:43:08 -0800
Message-ID: <20060127164308.1ea4c3e5.akpm@osdl.org>
References: <20060126185649.GB3651@localhost.localdomain>
	<20060126190357.GE3651@localhost.localdomain>
	<43D9DFA1.9070802@cosmosbay.com>
	<20060127195227.GA3565@localhost.localdomain>
	<20060127121602.18bc3f25.akpm@osdl.org>
	<20060127224433.GB3565@localhost.localdomain>
	<43DAA586.5050609@cosmosbay.com>
	<20060127151635.3a149fe2.akpm@osdl.org>
	<43DABAA4.8040208@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kiran@scalex86.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, shai@scalex86.org,
	netdev@vger.kernel.org, pravins@calsoftinc.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030358AbWA1AlX@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <43DABAA4.8040208@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <dada1@cosmosbay.com> wrote:
>
> > 
> > An advantage of retaining a spinlock in percpu_counter is that if accuracy
> > is needed at a low rate (say, /proc reading) we can take the lock and then
> > go spill each CPU's local count into the main one.  It would need to be a
> > very low rate though.   Or we make the cpu-local counters atomic too.
> 
> We might use atomic_long_t only (and no spinlocks)

Yup, that's it.

> Something like this ?
> 

It'd be a lot neater if we had atomic_long_xchg().
