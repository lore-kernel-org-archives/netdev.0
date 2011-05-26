From: Joe Perches <joe@perches.com>
Subject: Re: [patch] net/core/filter.c: Fix build error
Date: Thu, 26 May 2011 12:07:55 -0700
Message-ID: <1306436876.16087.25.camel@Joe-Laptop>
References: <efa062542c692c3f7743bf2d97b5987ab989e27e.1305999731.git.joe@perches.com>
	 <20110526123153.GA16002@elte.hu> <1306423866.16087.10.camel@Joe-Laptop>
	 <20110526.143843.205897228685761536.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, greearb@candelatech.com,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	arnd@arndb.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110526.143843.205897228685761536.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-05-26 at 14:38 -0400, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Thu, 26 May 2011 08:31:06 -0700
> > My suggestion would be to see about again adding
> > #include <linux/ratelimit.h> somehow
> > back to kernel.h which commit 3fff4c42bd0a removed
> > in 2009 because of the spinlock issues.
> > Any suggestion on how best to fix it generically?
> I don't think we want spinlock_t's definition being sucked
> into kernel.h's dependency food chain.
> Even if desirable, I think it'd be quite a bit of surgery,
> too much to do at this stage.
> So for now how about we make the ratelimit warn interfaces be a true,
> instead of a pseudo, dependency on ratelimit.h by moving those
> definitions into ratelimit.h?

Thanks, I suppose that's good enough for now.

Perhaps it'd also be good to move the pr_<level>_ratelimited
declarations from printk.h.

It seems that would not cause new compilation problems.

$ grep -rP --include=*.[ch] -wl "pr_[a-z]+_ratelimited" * | \
  xargs grep -L "include.*ratelimit\.h"
include/linux/printk.h

And, though it's sure to cause some compilation problems:

$ grep -rP --include=*.[ch] -wl "printk_ratelimit" * | \
  xargs grep -L "include.*ratelimit\.h" | wc -l
127

Perhaps it'd also be good to move the printk_ratelimit
block from printk.h into ratelimited.h and add
#include <linux/ratelimited.h> to the current source
files that use it in a later patchset.

Maybe Jiri could pick it up through trivial.  Jiri?
