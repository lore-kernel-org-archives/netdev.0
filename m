From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] unix: properly account for FDs passed over unix sockets
Date: Thu, 31 Dec 2015 08:12:53 +0100
Message-ID: <20151231071253.GG14369@1wt.eu>
References: <20151228141435.GA13351@1wt.eu> <56829D4D.4090109@stressinduktion.org> <20151229203527.GA13826@1wt.eu> <56839CC2.9080000@stressinduktion.org> <20151230112317.GC14049@1wt.eu> <201512311508.EJC90618.VtSOFFLQHFOJOM@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hannes@stressinduktion.org, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	torvalds@linux-foundation.org, edumazet@google.com,
	socketpair@gmail.com
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201512311508.EJC90618.VtSOFFLQHFOJOM@I-love.SAKURA.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 31, 2015 at 03:08:53PM +0900, Tetsuo Handa wrote:
> Willy Tarreau wrote:
> > On Wed, Dec 30, 2015 at 09:58:42AM +0100, Hannes Frederic Sowa wrote:
> > > The MSG_PEEK code should not be harmful and the patch is good as is. I 
> > > first understood from the published private thread, that it is possible 
> > > for a program to exceed the rlimit of fds. But the DoS is only by 
> > > keeping the fds in flight and not attaching them to any program.
> > 
> > Exactly. The real issue is when these FDs become very expensive such as
> > pipes full of data.
> > 
> 
> As you wrote how to abuse this vulnerability which exists in Linux 2.0
> and later kernel, I quote a short description from private thread.
> 
>   "an unprivileged user consumes all file descriptors so that other
>   unprivileged user cannot work" and "an unprivileged user consumes all
>   kernel memory so that the OOM killer kills almost all processes before
>   the culprit process is killed (CVE-2013-4312)".
> 
> Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Mitigates: CVE-2013-4312 (Linux 2.0+)

Well I didn't reveal any secret as it was publicly reported first
in 2010, it's only that Mark sent us the proof of concept exploit
on the security list recently :-)

    https://bugzilla.kernel.org/show_bug.cgi?id=20402

Anyway I'll resend the patch with your reported-by, the CVE and
Hannes' ACK.

Thanks!
Willy
