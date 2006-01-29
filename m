From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [patch 3/4] net: Percpufy frequently used variables -- proto.sockets_allocated
Date: Sat, 28 Jan 2006 19:44:59 -0500
Message-ID: <20060129004459.GA24099@kvack.org>
References: <20060126185649.GB3651@localhost.localdomain> <20060126190357.GE3651@localhost.localdomain> <43D9DFA1.9070802@cosmosbay.com> <20060127195227.GA3565@localhost.localdomain> <20060127121602.18bc3f25.akpm@osdl.org> <20060127224433.GB3565@localhost.localdomain> <43DAA586.5050609@cosmosbay.com> <20060127151635.3a149fe2.akpm@osdl.org> <43DABAA4.8040208@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, kiran@scalex86.org,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	shai@scalex86.org, netdev@vger.kernel.org, pravins@calsoftinc.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750795AbWA2AtS@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Content-Disposition: inline
In-Reply-To: <43DABAA4.8040208@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 28, 2006 at 01:28:20AM +0100, Eric Dumazet wrote:
> We might use atomic_long_t only (and no spinlocks)
> Something like this ?

Erk, complex and slow...  Try using local_t instead, which is substantially 
cheaper on the P4 as it doesn't use the lock prefix and act as a memory 
barrier.  See asm/local.h.

		-ben
