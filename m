From: "David S. Miller" <davem@redhat.com>
Subject: Re: possible bug in tcp_input.c
Date: Sun, 26 Oct 2003 22:33:18 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031026223318.41917bb0.davem@redhat.com>
References: <20031024162959.GB11154@louise.pinerecords.com>
	<20031024193034.30f1caed.davem@redhat.com>
	<20031026065519.GC28035@louise.pinerecords.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, grof@dragon.cz,
        volf@dragon.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: Tomas Szepe <szepe@pinerecords.com>
In-Reply-To: <20031026065519.GC28035@louise.pinerecords.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 26 Oct 2003 07:55:19 +0100
Tomas Szepe <szepe@pinerecords.com> wrote:

> Dave, we've been thinking about this some more and have concluded
> that since the problem is a relatively non-fatal one, the kernel
> should just print out an "assertion failed" error similar to the
> one in tcp_input.c, line 1323 [BUG_TRAP(cnt <= tp->packets_out);]
> and maybe fix things up a little rather than oops on a NULL pointer
> dereference;  The state in question, although invalid, is possible
> and should IMHO be checked for as in all the other "if (skb != NULL)
> ..." places).

If this condition triggers, the lists are corrupt and the kernel
should not try to access this socket in any way whatsoever
past this point.

Therefore it should OOPS, which is exactly what it does now.
A BUG_ON() is an equivalent response as far as I am concerned,
it has the same exact result, and the backtrace shows where the
problem is occuring.
