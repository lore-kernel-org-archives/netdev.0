From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] unix: properly account for FDs passed over unix sockets
Date: Thu, 31 Dec 2015 10:27:34 +0000
Message-ID: <20151231102734.6414538a@lxorguk.ukuu.org.uk>
References: <20151228141435.GA13351@1wt.eu>
	<56829D4D.4090109@stressinduktion.org>
	<20151229203527.GA13826@1wt.eu>
	<56839CC2.9080000@stressinduktion.org>
	<20151230112317.GC14049@1wt.eu>
	<201512311508.EJC90618.VtSOFFLQHFOJOM@I-love.SAKURA.ne.jp>
	<20151231071253.GG14369@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	hannes@stressinduktion.org, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	torvalds@linux-foundation.org, edumazet@google.com,
	socketpair@gmail.com
To: Willy Tarreau <w@1wt.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151231071253.GG14369@1wt.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 31 Dec 2015 08:12:53 +0100
Willy Tarreau <w@1wt.eu> wrote:

> On Thu, Dec 31, 2015 at 03:08:53PM +0900, Tetsuo Handa wrote:
> > Willy Tarreau wrote:
> > > On Wed, Dec 30, 2015 at 09:58:42AM +0100, Hannes Frederic Sowa wrote:
> > > > The MSG_PEEK code should not be harmful and the patch is good as is. I 
> > > > first understood from the published private thread, that it is possible 
> > > > for a program to exceed the rlimit of fds. But the DoS is only by 
> > > > keeping the fds in flight and not attaching them to any program.
> > > 
> > > Exactly. The real issue is when these FDs become very expensive such as
> > > pipes full of data.
> > > 
> > 
> > As you wrote how to abuse this vulnerability which exists in Linux 2.0
> > and later kernel, I quote a short description from private thread.
> > 
> >   "an unprivileged user consumes all file descriptors so that other
> >   unprivileged user cannot work" and "an unprivileged user consumes all
> >   kernel memory so that the OOM killer kills almost all processes before
> >   the culprit process is killed (CVE-2013-4312)".
> > 
> > Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Mitigates: CVE-2013-4312 (Linux 2.0+)
> 
> Well I didn't reveal any secret as it was publicly reported first
> in 2010, it's only that Mark sent us the proof of concept exploit
> on the security list recently :-)

There were demonstrations of this bug posted for BSD unixes before Linux
even existed. It and "run the box out of socket buffers" are older than
Linux 8)

Alan
