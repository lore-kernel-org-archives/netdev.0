From: "David S. Miller" <davem@davemloft.net>
Subject: Re: way of figuring out total number of retransmitted packets on a
 TCP socket?
Date: Wed, 20 Oct 2004 15:53:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020155352.1c9b70f6.davem@davemloft.net>
References: <20041020130134.GC24757@xi.wantstofly.org>
	<20041020151448.51209278.davem@davemloft.net>
	<20041020223547.GJ29583@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20041020223547.GJ29583@xi.wantstofly.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 21 Oct 2004 00:35:47 +0200
Lennert Buytenhek <buytenh@wantstofly.org> wrote:

> Some places in the TCP stack reset tp->retransmits to zero, or to
> one.  Is it supposed to reflect the current number of retransmitted
> packets in the network?

Yes, timeout based retransmits in the network.  It is reset typically
when the connection is healthy again and making forward progress on
the lost packets.

> > Retransmits which occur dynamically due to fast-retransmit
> > and other non-timeout based decisions are accounted for
> > in "tcpi_retrans", so that is probably the value you are
> > looking for.
> 
> tcpi_retrans is taken from tp->retrans_out (looking at 2.6.8 here.)
> But that value gets set to zero in a lot of places in the networking
> as well, so it's probably not what I'm looking for either.

I agree.  We could easily add the thing you are looking for.  It's
just another statistic, zero'd at socket creation time and incremented
right under the line which reads:

		/* Update global TCP statistics. */
		TCP_INC_STATS(TCP_MIB_RETRANSSEGS);

in tcp_retransmit_skb().

I'll add this for you.
