From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH RFC] v1 expedited "big hammer" RCU grace periods
Date: Thu, 23 Apr 2009 08:47:02 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0904230842571.3101@localhost.localdomain>
References: <20090423052520.GA13036@linux.vnet.ibm.com> <20090423075436.GB22606@elte.hu> <20090423153402.GC6877@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	dada1@cosmosbay.com, zbr@ioremap.net, jeff.chua.linux@gmail.com,
	paulus@samba.org, laijs@cn.fujitsu.com, jengelh@medozas.de,
	r000n@r000n.net, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090423153402.GC6877@linux.vnet.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Thu, 23 Apr 2009, Paul E. McKenney wrote:
> 
> Hmmm...  I need to ask Jeff Chua what HZ he was running with.  Because if
> there was some read-side critical section soaking up 30 milliseconds,
> all that hammering will do is slow things down...

The original bug report comes from simply bootup:

  "I'm loading all the firewall rules during boot-up and this 6 secs 
   slowness is really not very nice to wait for."

IOW, the problematic case likely effectively has _nothing_ else going on. 
Sure, there might be some parallelism (the bootup scripts are getting 
better for that), but hopefully not 6 seconds worth, and not likely any 
complex critical sections.

		Linus
