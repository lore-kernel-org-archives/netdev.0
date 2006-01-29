From: Kyle McMartin <kyle@parisc-linux.org>
Subject: Re: [patch 3/4] net: Percpufy frequently used variables -- proto.sockets_allocated
Date: Sat, 28 Jan 2006 20:45:14 -0500
Message-ID: <20060129014514.GA32305@tachyon.int.mcmartin.ca>
References: <43D9DFA1.9070802@cosmosbay.com> <20060127195227.GA3565@localhost.localdomain> <20060127121602.18bc3f25.akpm@osdl.org> <20060127224433.GB3565@localhost.localdomain> <43DAA586.5050609@cosmosbay.com> <20060127151635.3a149fe2.akpm@osdl.org> <43DABAA4.8040208@cosmosbay.com> <20060129004459.GA24099@kvack.org> <20060128165549.262f2b90.akpm@osdl.org> <20060129011944.GB24099@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, dada1@cosmosbay.com,
	kiran@scalex86.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, shai@scalex86.org,
	netdev@vger.kernel.org, pravins@calsoftinc.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750809AbWA2BpE@vger.kernel.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Content-Disposition: inline
In-Reply-To: <20060129011944.GB24099@kvack.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 28, 2006 at 08:19:44PM -0500, Benjamin LaHaise wrote:
> The overuse of atomics is horrific in what is being proposed.  All the
> major architectures except powerpc (i386, x86-64, ia64, and sparc64) 
> implement local_t.  It would make far more sense to push the last few 
> stragglers (which mostly seem to be uniprocessor) into writing the 
> appropriate implementations.  Perhaps it's time to add a #error in 
> asm-generic/local.h?
>

Surely asm-generic/local.h could now be reimplemented using atomic_long_t
to kill that aberration that is the BITS_PER_LONG != 32 case currently...? 
