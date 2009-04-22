From: Greg Lindahl <greg@blekko.com>
Subject: Re: [PATCH] LSM: Add security_socket_post_accept() and
	security_socket_post_recv_datagram().
Date: Tue, 21 Apr 2009 18:52:28 -0700
Message-ID: <20090422015228.GA13312@bx9.net>
References: <200904212152.FHH51019.MHOFVtOFSJFQOL@I-love.SAKURA.ne.jp> <20090421.060404.146628527.davem@davemloft.net> <200904220055.n3M0tQ6T048840@www262.sakura.ne.jp> <20090421.181411.26595688.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: penguin-kernel@i-love.sakura.ne.jp, paul.moore@hp.com,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090421.181411.26595688.davem@davemloft.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 21, 2009 at 06:14:11PM -0700, David Miller wrote:

> We had a similar situation with read()'s on UDP sockets.
> 
> When poll() says something, it has to stick.

Isn't that completely different? Anyone who writes code that calls
accept() quickly finds out that in the real world it fails for all
kinds of reasons worth ignoring. As an example, a comment in ircd at
the only accept call (circa 1998):

   /*
   ** There may be many reasons for error return, but in otherwise
   ** correctly working environment the probable cause is running
   ** out of file descriptors (EMFILE, ENFILE or others?). The
   ** man pages for accept don't seem to list these as possible,
   ** although it's obvious that it may happen here.
   ** Thus no specific errors are tested at this point, just
   ** assume that connections cannot be accepted until some old
   ** is closed first.
   */

And it silently ignores EAGAIN, which of course is a can't happen when
used with select(). The recently-written only-runs-on-Linux system I'm
working on ignores EAGAIN, even though it's a can't happen with
epoll. I can ask the guy who wrote it, but he's probably ignoring it
because he was frequently seeing them.

I'd be surprised if you found much real-life code that didn't
gracefully tolerate accept failures. Can anyone come up with an
example?

-- greg

