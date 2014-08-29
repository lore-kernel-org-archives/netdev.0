From: Julian Anastasov <ja@ssi.bg>
Subject: Re: net_ns cleanup / RCU overhead
Date: Fri, 29 Aug 2014 06:57:55 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1408290635530.1520@ja.home.ssi.bg>
References: <20140820055855.GB5579@hostway.ca> <20140828192431.GF5001@linux.vnet.ibm.com> <20140828194422.GB8867@hostway.ca> <87oav4l5g9.fsf@x220.int.ebiederm.org> <20140828204658.GL5001@linux.vnet.ibm.com> <20140829004029.GA18300@hostway.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Simon Kirby <sim@hostway.ca>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140829004029.GA18300@hostway.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Hello,

On Thu, 28 Aug 2014, Simon Kirby wrote:

> I noticed that [kworker/u16:0]'s stack is often:
> 
> [<ffffffff810942a6>] wait_rcu_gp+0x46/0x50
> [<ffffffff8109607e>] synchronize_sched+0x2e/0x50
> [<ffffffffa00385ac>] nf_nat_net_exit+0x2c/0x50 [nf_nat]

	I guess the problem is in nf_nat_net_exit,
may be other nf exit handlers too. pernet-exit handlers
should avoid synchronize_rcu and rcu_barrier.
A RCU callback and rcu_barrier in module-exit is the way
to go. cleanup_net includes rcu_barrier, so pernet-exit
does not need such calls.

> [<ffffffff81720339>] ops_exit_list.isra.4+0x39/0x60
> [<ffffffff817209e0>] cleanup_net+0xf0/0x1a0
> [<ffffffff81062997>] process_one_work+0x157/0x440
> [<ffffffff81063303>] worker_thread+0x63/0x520
> [<ffffffff81068b96>] kthread+0xd6/0xf0
> [<ffffffff818d412c>] ret_from_fork+0x7c/0xb0
> [<ffffffffffffffff>] 0xffffffffffffffff

Regards

--
Julian Anastasov <ja@ssi.bg>
