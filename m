From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [patch 3/4] net: Percpufy frequently used variables -- proto.sockets_allocated
Date: Sat, 28 Jan 2006 20:19:44 -0500
Message-ID: <20060129011944.GB24099@kvack.org>
References: <20060126190357.GE3651@localhost.localdomain> <43D9DFA1.9070802@cosmosbay.com> <20060127195227.GA3565@localhost.localdomain> <20060127121602.18bc3f25.akpm@osdl.org> <20060127224433.GB3565@localhost.localdomain> <43DAA586.5050609@cosmosbay.com> <20060127151635.3a149fe2.akpm@osdl.org> <43DABAA4.8040208@cosmosbay.com> <20060129004459.GA24099@kvack.org> <20060128165549.262f2b90.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dada1@cosmosbay.com, kiran@scalex86.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, shai@scalex86.org,
	netdev@vger.kernel.org, pravins@calsoftinc.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750804AbWA2BYM@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060128165549.262f2b90.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 28, 2006 at 04:55:49PM -0800, Andrew Morton wrote:
> local_t isn't much use until we get rid of asm-generic/local.h.  Bloaty,
> racy with nested interrupts.

The overuse of atomics is horrific in what is being proposed.  All the
major architectures except powerpc (i386, x86-64, ia64, and sparc64) 
implement local_t.  It would make far more sense to push the last few 
stragglers (which mostly seem to be uniprocessor) into writing the 
appropriate implementations.  Perhaps it's time to add a #error in 
asm-generic/local.h?

		-ben
-- 
"Ladies and gentlemen, I'm sorry to interrupt, but the police are here 
and they've asked us to stop the party."  Don't Email: <dont@kvack.org>.
