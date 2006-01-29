From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 3/4] net: Percpufy frequently used variables --
 proto.sockets_allocated
Date: Sat, 28 Jan 2006 16:55:49 -0800
Message-ID: <20060128165549.262f2b90.akpm@osdl.org>
References: <20060126185649.GB3651@localhost.localdomain>
	<20060126190357.GE3651@localhost.localdomain>
	<43D9DFA1.9070802@cosmosbay.com>
	<20060127195227.GA3565@localhost.localdomain>
	<20060127121602.18bc3f25.akpm@osdl.org>
	<20060127224433.GB3565@localhost.localdomain>
	<43DAA586.5050609@cosmosbay.com>
	<20060127151635.3a149fe2.akpm@osdl.org>
	<43DABAA4.8040208@cosmosbay.com>
	<20060129004459.GA24099@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, kiran@scalex86.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, shai@scalex86.org,
	netdev@vger.kernel.org, pravins@calsoftinc.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750797AbWA2A4V@vger.kernel.org>
To: Benjamin LaHaise <bcrl@kvack.org>
In-Reply-To: <20060129004459.GA24099@kvack.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Benjamin LaHaise <bcrl@kvack.org> wrote:
>
> On Sat, Jan 28, 2006 at 01:28:20AM +0100, Eric Dumazet wrote:
> > We might use atomic_long_t only (and no spinlocks)
> > Something like this ?
> 
> Erk, complex and slow...  Try using local_t instead, which is substantially 
> cheaper on the P4 as it doesn't use the lock prefix and act as a memory 
> barrier.  See asm/local.h.
> 

local_t isn't much use until we get rid of asm-generic/local.h.  Bloaty,
racy with nested interrupts.
