From: Dhaval Giani <dhaval.giani@gmail.com>
Subject: Re: [PATCH v2 tip/core/rcu 05/13] decnet: Apply rcu_access_pointer()
 to avoid sparse false positive
Date: Wed, 9 Oct 2013 18:58:47 -0400
Message-ID: <CAPhKKr8kLDNd7CdksHriyMzsqcj0oSf7mAfLceviMjobYGy7oA@mail.gmail.com>
References: <20131009212920.GA15413@linux.vnet.ibm.com>
	<1381354186-16285-1-git-send-email-paulmck@linux.vnet.ibm.com>
	<1381354186-16285-5-git-send-email-paulmck@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: LKML <linux-kernel@vger.kernel.org>, mingo@kernel.org,
	laijs@cn.fujitsu.com, Dipankar <dipankar@in.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
	josh@joshtriplett.org, Nivedita Singhvi <niv@us.ibm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	David Howells <dhowells@redhat.com>, edumazet@google.com,
	Darren Hart <darren@dvhart.com>,
	Frederic Weisbecker <fweisbec@gmail.com>, sbw@mit.edu,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>, Gao feng <gaofeng@cn.fujitsu.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	linux-decnet-user@lists.sourceforge.net, netdev@vger.kernel.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1381354186-16285-5-git-send-email-paulmck@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 9, 2013 at 5:29 PM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
>
> From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
>
> The sparse checking for rcu_assign_pointer() was recently upgraded
> to reject non-__kernel address spaces.  This also rejects __rcu,
> which is almost always the right thing to do.  However, the use in
> dn_insert_route() is legitimate: It is assigning a pointer to an element
> from an RCU-protected list, and all elements of this list are already
> visible to caller.
>
> This commit therefore silences this false positive by laundering the
> pointer using rcu_access_pointer() as suggested by Josh Triplett.
>
> Reported-by: kbuild test robot <fengguang.wu@intel.com>


I did not realize that we were allowed to rename people :-)

Thanks!
Dhaval
