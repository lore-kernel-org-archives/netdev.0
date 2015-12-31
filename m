From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] unix: properly account for FDs passed over unix sockets
Date: Thu, 31 Dec 2015 15:08:53 +0900
Message-ID: <201512311508.EJC90618.VtSOFFLQHFOJOM@I-love.SAKURA.ne.jp>
References: <20151228141435.GA13351@1wt.eu>
	<56829D4D.4090109@stressinduktion.org>
	<20151229203527.GA13826@1wt.eu>
	<56839CC2.9080000@stressinduktion.org>
	<20151230112317.GC14049@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, torvalds@linux-foundation.org,
	edumazet@google.com, socketpair@gmail.com
To: w@1wt.eu, hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:61935 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751266AbbLaGIz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Dec 2015 01:08:55 -0500
In-Reply-To: <20151230112317.GC14049@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Willy Tarreau wrote:
> On Wed, Dec 30, 2015 at 09:58:42AM +0100, Hannes Frederic Sowa wrote:
> > The MSG_PEEK code should not be harmful and the patch is good as is. I 
> > first understood from the published private thread, that it is possible 
> > for a program to exceed the rlimit of fds. But the DoS is only by 
> > keeping the fds in flight and not attaching them to any program.
> 
> Exactly. The real issue is when these FDs become very expensive such as
> pipes full of data.
> 

As you wrote how to abuse this vulnerability which exists in Linux 2.0
and later kernel, I quote a short description from private thread.

  "an unprivileged user consumes all file descriptors so that other
  unprivileged user cannot work" and "an unprivileged user consumes all
  kernel memory so that the OOM killer kills almost all processes before
  the culprit process is killed (CVE-2013-4312)".

Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Mitigates: CVE-2013-4312 (Linux 2.0+)
