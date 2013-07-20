From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: strange crashes in tcp_poll() via epoll_wait
Date: Fri, 19 Jul 2013 17:10:05 -0700
Message-ID: <1374279005.26476.31.camel@edumazet-glaptop>
References: <1374251057.26476.17.camel@edumazet-glaptop>
	 <20130719235008.GA4518@dcvr.yhbt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Al Viro <viro@ZenIV.linux.org.uk>, netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Eric Wong <normalperson@yhbt.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130719235008.GA4518@dcvr.yhbt.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-07-19 at 23:50 +0000, Eric Wong wrote:
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > Hi Al
> > 
> > I tried to debug strange crashes in tcp_poll() called from
> > sys_epoll_wait() -> sock_poll()
> > 
> > The symptom is that sock->sk is NULL and we therefore dereference a NULL
> > pointer.
> > 
> > It's really rare crashes but still, it would be nice to understand where
> > is the bug. Presumably latest kernels would crash in sock_poll() because
> > of the sk_can_busy_loop(sock->sk) call.
> > 
> > We do test sock->sk being NULL in sock_fasync(), but epoll should be
> > safe because of existing synchronization (epmutex) ?
> 
> It should be safe because of ep->mtx, actually, as epmutex is not taken
> in sys_epoll_wait.

Hmm, it might be more complex than that for multi threaded programs : 

eventpoll_release_file()

The problem might be because a thread closes a socket while an event
was queued for it.


> 
> I took a look at this but have not found anything.  I've yet to see this
> this on my machines.
> 
> When did you start noticing this?

Hard to say, but we have these crashes on a 3.3+ based kernel.

Probability of said crashes is very very low.
