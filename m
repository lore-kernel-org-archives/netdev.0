From: "David S. Miller" <davem@davemloft.net>
Subject: Re: routing table improvements
Date: Sun, 24 Oct 2004 20:41:34 -0700
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <20041024204134.542420ce.davem@davemloft.net>
References: <876ef97a04102417193517f48f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com,
	netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Tobias DiPasquale <codeslinger@gmail.com>
In-Reply-To: <876ef97a04102417193517f48f@mail.gmail.com>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Sun, 24 Oct 2004 20:19:55 -0400
Tobias DiPasquale <codeslinger@gmail.com> wrote:

> First of all, is anyone else doing something in this area?

Yes, this has been discussed on this list over the past
2 months.  Let me save you some time:

1) We are already working on abstracting out the algorithmic
   portions of net/ipv4/fib_hash.c, see recent changeset
   history of this file in 2.6.x for details

2) Using the BSD Radix tree will not improve performance,
   it has the same algorithmic complexity as the current
   32-hashtable algorithm for large routing tables

3) Once the complexity of the mid-level routing table FIB
   algorithms is made better, there is no evidence that this
   means the routing cache should be removed.

   You should instead evaluate it's performance after the
   mid-level algorithms perform acceptably.

If you remove the routing cache, I don't believe you understand
the implications of this.  Firstly, you have to store the
routing metrics for every remote host we talk to, where do you
plan to store this and what will it be keyed upon?  How will you
handle per-socket routes?  How will you handle the interface with
the IPSEC layer which uses trees of routing cache entries as it's
fundamental object type?

Please scan the list postings, particularly on netdev, and I've
even given a keynote on our planned work just the other week in
Tokyo.
