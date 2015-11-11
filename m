From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 2/2] arm64: bpf: add BPF XADD instruction
Date: Wed, 11 Nov 2015 19:44:27 +0100
Message-ID: <20151111184427.GH11639@twins.programming.kicks-ass.net>
References: <56436420.9090401@iogearbox.net>
 <20151111162341.GN9562@arm.com>
 <20151111172659.GA86334@ast-mbp.thefacebook.com>
 <20151111.123548.1039494689070388545.davem@davemloft.net>
 <20151111175741.GR17308@twins.programming.kicks-ass.net>
 <20151111181132.GA90947@ast-mbp.thefacebook.com>
 <20151111183128.GS17308@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, will.deacon@arm.com,
	daniel@iogearbox.net, arnd@arndb.de, yang.shi@linaro.org,
	linaro-kernel@lists.linaro.org, eric.dumazet@gmail.com,
	zlim.lnx@gmail.com, ast@kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, xi.wang@gmail.com, catalin.marinas@arm.com,
	linux-arm-kernel@lists.infradead.org, yhs@plumgrid.com,
	bblanco@plumgrid.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151111183128.GS17308@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 11, 2015 at 07:31:28PM +0100, Peter Zijlstra wrote:
> > Add new one that does 'fetch_and_add' ? What is the real use case it
> > will be used for?
> 
> Look at all the atomic_{add,dec}_return*() users in the kernel. A typical
> example would be a reader-writer lock implementations. See
> include/asm-generic/rwsem.h for examples.

Maybe a better example would be refcounting, where you free on 0.

	if (!fetch_add(&obj->ref, -1))
		free(obj);
