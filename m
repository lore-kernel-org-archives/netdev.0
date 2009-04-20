From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] netfilter: use per-cpu recursive lock (v10)
Date: Mon, 20 Apr 2009 16:44:46 -0700
Message-ID: <20090420234446.GL6822@linux.vnet.ibm.com>
References: <20090416.153354.170676392.davem@davemloft.net> <20090416234955.GL6924@linux.vnet.ibm.com> <20090417012812.GA25534@linux.vnet.ibm.com> <20090418094001.GA2369@ioremap.net> <20090418141455.GA7082@linux.vnet.ibm.com> <20090420103414.1b4c490f@nehalam> <49ECBE0A.7010303@cosmosbay.com> <18924.59347.375292.102385@cargo.ozlabs.ibm.com> <20090420215827.GK6822@linux.vnet.ibm.com> <18924.64032.103954.171918@cargo.ozlabs.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	torvalds@linux-foundation.org, jeff.chua.linux@gmail.com,
	mingo@elte.hu, laijs@cn.fujitsu.com, jengelh@medozas.de,
	r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org, mathieu.desnoyers@polymtl.ca
To: Paul Mackerras <paulus@samba.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <18924.64032.103954.171918@cargo.ozlabs.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 21, 2009 at 08:41:36AM +1000, Paul Mackerras wrote:
> Paul E. McKenney writes:
> 
> > But a single CPU is acquiring one lock per CPU, so all the increments
> > are to one CPU's preempt_count.  :-(
> 
> OK, I see, so a task can't take more than 255 spinlocks without
> overflowing the preempt count, which seems a bit limiting.
> 
> There are 6 free bits in the preempt_count currently, so the preempt
> count could be expanded to 14 bits, which would be enough for all
> current systems.  Beyond that I guess we could make preempt_count be a
> long and allow bigger counts on 64-bit architectures.

Or we use the trick Eric suggested and Steve employed in the most recent
patch.  ;-)

An alternative would be for the update code to acquire but one lock at a
time, but this would likely require another lock to exclude other
updaters and I believe would also require restructuring the count
accumulation.

So Steve's current patch seems a bit less intrusive, overall.

							Thanx, Paul
