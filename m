From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: do_gettimeofday
Date: Fri, 3 Oct 2003 01:48:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031003084847.GH42593@gaz.sfgoth.com>
References: <3F7C6F3B.6070502@sgi.com> <20031002125625.72b8c0a7.shemminger@osdl.org> <20031003004133.3148c39a.davem@redhat.com> <20031003082642.GF42593@gaz.sfgoth.com> <20031003012754.23de3f66.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031003012754.23de3f66.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> Doesn't work as-is.  You'd have to not only store the timestamp and
> the cpu it was stored on, but also cross-call to that cpu to compute
> the correct timeval.

That's definately the worst case.  You could have each CPU periodically
store its current {tsc,timeval} tuple in a per-cpu location and extrapolate
from that.

> That's really expensive and probably
> do_gettimeofday() is going to be faster in the long run compared to
> such a scheme.

It all depends on what percentage of skb's have ->stamp computed on a
CPU different from the one they came it on.  For the common users of
->stamp won't they have stayed on the same CPU?  The worst case of
doing a cross-cpu-call should only happen relatively rarely.

-Mitch
