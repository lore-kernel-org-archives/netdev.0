From: "David S. Miller" <davem@davemloft.net>
Subject: Re: TSO prevents cwnd growth on 2.6 kernels
Date: Fri, 25 Mar 2005 10:40:00 -0800
Message-ID: <20050325104000.713229be.davem@davemloft.net>
References: <20050325181804.GA11633@visi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: "Scott M. Ferris" <sferris@acm.org>
In-Reply-To: <20050325181804.GA11633@visi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 25 Mar 2005 12:18:04 -0600
"Scott M. Ferris" <sferris@acm.org> wrote:

> TSO still has problems in 2.6.12-rc1. 

We know it's busted.  I haven't gotten to fixing this stuff
up yet.

> tcp_write_xmit() really needs to be willing to increase
> tcp_packets_in_flight() high enough that tcp_ack() will allow the
> congestion window to grow, even when TSO is being used, otherwise
> there may be a dramatic reduction in the cwnd growth rate.

Are you suggesting to let it go past tp->snd_cwnd?  We can't
ever do that.  tp->snd_cwnd is a hard limit on the number
of frames we may have outstanding on the network at one time,
TSO or not.
