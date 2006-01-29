From: Andi Kleen <ak@suse.de>
Subject: Re: [patch 3/4] net: Percpufy frequently used variables -- proto.sockets_allocated
Date: Sun, 29 Jan 2006 06:38:17 +0100
Message-ID: <200601290638.18630.ak@suse.de>
References: <20060126185649.GB3651@localhost.localdomain> <20060129004459.GA24099@kvack.org> <20060128165549.262f2b90.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Benjamin LaHaise <bcrl@kvack.org>, dada1@cosmosbay.com,
	kiran@scalex86.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, shai@scalex86.org,
	netdev@vger.kernel.org, pravins@calsoftinc.com,
	linux-arch@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750836AbWA2Fi2@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060128165549.262f2b90.akpm@osdl.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[adding linux-arch]

On Sunday 29 January 2006 01:55, Andrew Morton wrote:
> Benjamin LaHaise <bcrl@kvack.org> wrote:
> > On Sat, Jan 28, 2006 at 01:28:20AM +0100, Eric Dumazet wrote:
> > > We might use atomic_long_t only (and no spinlocks)
> > > Something like this ?
> >
> > Erk, complex and slow...  Try using local_t instead, which is
> > substantially cheaper on the P4 as it doesn't use the lock prefix and act
> > as a memory barrier.  See asm/local.h.
>
> local_t isn't much use until we get rid of asm-generic/local.h.  Bloaty,
> racy with nested interrupts.

It is just implemented wrong. It should use 
local_irq_save()/local_irq_restore() instead. But my bigger problem
with local_t is these few architectures (IA64, PPC64) who implement it 
with atomic_t. This means we can't replace local statistics counters
with local_t because it would be regression for them. I haven't done the
benchmarks yet, but I suspect both IA64 and PPC64 really should
just turn off interrupts.

-Andi
