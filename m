From: "David S. Miller" <davem@davemloft.net>
Subject: Re: way of figuring out total number of retransmitted packets on a
 TCP socket?
Date: Wed, 20 Oct 2004 15:14:48 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020151448.51209278.davem@davemloft.net>
References: <20041020130134.GC24757@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20041020130134.GC24757@xi.wantstofly.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 20 Oct 2004 15:01:34 +0200
Lennert Buytenhek <buytenh@wantstofly.org> wrote:

> I'm looking for a way of counting the total number of retransmitted packets
> sent on a TCP connection.  I tried querying TCP_INFO:tcpi_retransmits, but
> that seems to be not the metric I'm looking for.
> 
> Anyone got any ideas?  (Apart from using tcpdump+tcptrace.)

tcpi_retransmits only accounts for timeout based retransmits.

Retransmits which occur dynamically due to fast-retransmit
and other non-timeout based decisions are accounted for
in "tcpi_retrans", so that is probably the value you are
looking for.

Unlike another person's response to this thread, you don't
need the huge web100 patch to get at this information :-)
