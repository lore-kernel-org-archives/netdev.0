From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] UDP select handling of bad checksums.
Date: Wed, 3 Nov 2004 13:20:46 -0800
Message-ID: <20041103132046.02061e54@zqx3.pdx.osdl.net>
References: <20041102162454.3f153ff0@dxpl.pdx.osdl.net>
	<20041103005253.GA77817@gaz.sfgoth.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitchell Blank Jr <mitch@sfgoth.com>
In-Reply-To: <20041103005253.GA77817@gaz.sfgoth.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2 Nov 2004 16:52:53 -0800
Mitchell Blank Jr <mitch@sfgoth.com> wrote:

> Stephen Hemminger wrote:
> > This patch addresses the issue of blocking usage of select() by UDP applications.
> 
> I'm glad to see someone actually putting some code forward in this debate...
> Looks pretty good, but can't you implement this a bit cleaner by just
> wrapping datagram_poll?  Something like:

But the wrapper was bigger and uglier than just doing it.
Especially since UDP doesn't need to connection oriented checks.
So the fast path code in UDP is actually faster than datagram_poll.

> 
> That way you duplicate a lot less code.  It does slightly more work but
> only in the broken !O_NONBLOCK case - the fast path is just as quick.
> 
> -Mitch
