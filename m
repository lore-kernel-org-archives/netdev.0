From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] skb pcount with MTU discovery
Date: Fri, 1 Apr 2005 13:10:45 -0800
Message-ID: <20050401131045.4e558f65.davem@davemloft.net>
References: <Pine.LNX.4.58.0504011340510.17051@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <Pine.LNX.4.58.0504011340510.17051@dexter.psc.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 1 Apr 2005 16:05:49 -0500 (EST)
John Heffner <jheffner@psc.edu> wrote:

> The problem is that when doing MTU discovery, the too-large segments in
> the write queue will be calculated as having a pcount of >1.  When
> tcp_write_xmit() is trying to send, tcp_snd_test() fails the cwnd test
> when pcount > cwnd.
> 
> The segments are eventually transmitted one at a time by keepalive, but
> this can take a long time.
> 
> This patch checks if TSO is enabled when setting pcount.

Why isn't the MSS properly updated at this point in time?
If it were, the pcount setting would do the right thing.

That's how this code is supposed to work.
