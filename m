From: Greg Lindahl <greg@blekko.com>
Subject: Re: [PATCH] LSM: Add security_socket_post_accept() and
	security_socket_post_recv_datagram().
Date: Tue, 21 Apr 2009 23:54:43 -0700
Message-ID: <20090422065443.GC4221@bx9.net>
References: <20090422061006.GB27688@bx9.net> <20090421.233403.83067664.davem@davemloft.net> <20090422064159.GA4221@bx9.net> <20090421.234618.181879214.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: penguin-kernel@i-love.sakura.ne.jp, paul.moore@hp.com,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090421.234618.181879214.davem@davemloft.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 21, 2009 at 11:46:18PM -0700, David Miller wrote:

> EAGAIN does not happen if the application calls poll(), gets
> an indication that connections are available, and then
> immediately calls accept() on the indicated FD.

I have observed it recently and historically, and not by calling
accept() repeatedly. I don't know what you mean by "immediately" since I
don't think you're advocating race conditions; the other end can
always exit/reset/whatever between the poll() and the accept().

> If overly anal apps "code for it" that is entirely besides the point.
> What we have to be concerned for, from a kernel behavioral standpoint,
> is that some apps "might not code for it".  This is why we don't
> change behavior.

I am suggesting that you survey actual apps. If you find that they're
all overly anal, then maybe you've learned something about EAGAIN
already happening today. I assure you that the co-worker who stuck in
the "ignore EAGAIN without logging it" only did so because he saw it
fairly frequently. He's that way.

-- greg


