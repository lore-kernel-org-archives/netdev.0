From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] netfilter:  fix  race in conntrack between dump_table
 and destroy
Date: Tue, 30 Nov 2010 09:28:03 -0800
Message-ID: <20101130092803.53fde6af@nehalam>
References: <20101124222716.437c5547@nehalam>
	<1290666873.2798.89.camel@edumazet-laptop>
	<20101124230004.1dc28e5a@nehalam>
	<1290669214.2798.109.camel@edumazet-laptop>
	<20101126135101.4e4b97cc@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20101126135101.4e4b97cc@nehalam>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 26 Nov 2010 13:51:01 -0800
Stephen Hemminger <shemminger@vyatta.com> wrote:

> The netlink interface to dump the connection tracking table has a race
> when entries are deleted at the same time. A customer reported a crash 
> and the backtrace showed thatctnetlink_dump_table was running while a 
> conntrack entry wasbeing destroyed.
> (see https://bugzilla.vyatta.com/show_bug.cgi?id=6402).
> 
> According to RCU documentation, when using hlist_nulls the reader
> must handle the case of seeing a deleted entry and not proceed
> further down the linked list.  The old code would continue
> which caused the scan to walk into the free list. 
> 
> This patch uses locking (rather than RCU) for this operation which
> is guaranteed safe, and no longer requires getting reference while
> doing dump operation.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

This should go in net-2.6 and stable for 2.6.32, 2.6.35, and 2.6.36



-- 
