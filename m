From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [net-next:master 257/266]
 drivers/net/team/team_mode_loadbalance.c:99:30: sparse: incompatible types
 in comparison expression (different address spaces)
Date: Wed, 20 Jun 2012 15:23:29 +0200
Message-ID: <20120620132329.GD1580@minipsycho.brq.redhat.com>
References: <20120620042743.GA7640@localhost>
 <20120620063607.GA1491@minipsycho>
 <20120620065055.GA5872@localhost>
 <20120620124913.GF2432@linux.vnet.ibm.com>
 <1340197909.4604.956.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paulmck@linux.vnet.ibm.com, Fengguang Wu <wfg@linux.intel.com>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1340197909.4604.956.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wed, Jun 20, 2012 at 03:11:49PM CEST, eric.dumazet@gmail.com wrote:
>On Wed, 2012-06-20 at 05:49 -0700, Paul E. McKenney wrote:
>> On Wed, Jun 20, 2012 at 02:50:55PM +0800, Fengguang Wu wrote:
>> > [CC Paul, the RCU maintainer]
>> > 
>> > On Wed, Jun 20, 2012 at 08:36:07AM +0200, Jiri Pirko wrote:
>> > > Wed, Jun 20, 2012 at 06:27:43AM CEST, wfg@linux.intel.com wrote:
>> > > >Hi Jiri,
>> > > >
>> > > >There are new sparse warnings show up in
>> > > >
>> > > >tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
>> > > >head:   677a3d60fb3153f786a0d28fcf0287670e7bd3c2
>> > > >commit: ab8250d70063f77929fc404c02390a1f64d66416 [257/266] team: lb: introduce infrastructure for userspace driven tx loadbalancing
>> > > >
>> > > >All sparse warnings:
>> > > >
>> > > >drivers/net/team/team_mode_loadbalance.c:99:30: sparse: incompatible types in comparison expression (different address spaces)
>> > > >
>> > > >drivers/net/team/team_mode_loadbalance.c:99:
>> > > >    96			struct lb_port_mapping *pm;
>> > > >    97	
>> > > >    98			pm = &lb_priv->ex->tx_hash_to_port_mapping[i];
>> > > >  > 99			if (pm->port == port) {
>> > > 
>> > > This looks like your checker does not like
>> > > (struct team_port __rcu *) == (struct team_port *)
>> > > But I wonder why (or how should I fix that)
>> 
>> Because you said that it was an RCU-protected pointer, but then did
>> not use an RCU primitive to access it.  In this case, where you are
>> just using the value but not dereferencing it, you can use
>> rcu_access_pointer().
>
>Yes, and please Jiri change the 
>
>rcu_assign_pointer(pm->port, NULL);
>
>by
>
>RCU_INIT_POINTER(pm->port, NULL);

Will do.

>
>
>
