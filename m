From: "David S. Miller" <davem@redhat.com>
Subject: Re: do_gettimeofday
Date: Fri, 3 Oct 2003 01:27:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031003012754.23de3f66.davem@redhat.com>
References: <3F7C6F3B.6070502@sgi.com>
	<20031002125625.72b8c0a7.shemminger@osdl.org>
	<20031003004133.3148c39a.davem@redhat.com>
	<20031003082642.GF42593@gaz.sfgoth.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitchell Blank Jr <mitch@sfgoth.com>
In-Reply-To: <20031003082642.GF42593@gaz.sfgoth.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 3 Oct 2003 01:26:42 -0700
Mitchell Blank Jr <mitch@sfgoth.com> wrote:

> Are there any common cases where skb->stamp is looked at more than
> once?

Yes, the packet scheduler can cause this to happen.

>If so I might recommend changing the API to be more like:
> 
> 	const struct timeval *skb_timestamp(struct skbuff *skb);

Please no, making this a SKB or networking specific interface
make it nearly valueless and we might as well just stay with the
stuff we have.


> > Platforms with inter-cpu TSC synchronization issues will have some
> > troubles doing the same trick too, because one must handle properly
> > the case where the fast timestamp is converted to a timeval on a different
> > cpu on which the fast timestamp was recorded.
> 
> Yeah, you'd probably have something like

Doesn't work as-is.  You'd have to not only store the timestamp and
the cpu it was stored on, but also cross-call to that cpu to compute
the correct timeval.  That's really expensive and probably
do_gettimeofday() is going to be faster in the long run compared to
such a scheme.
