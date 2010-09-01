From: David Rientjes <rientjes@google.com>
Subject: Re: How can OOM killer detect process consuming much kernel
 memory?
Date: Wed, 1 Sep 2010 15:25:14 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1009011519070.29305@chino.kir.corp.google.com>
References: <201008212101.IJG87048.QMOHFtSOVOLFFJ@I-love.SAKURA.ne.jp> <AANLkTi=oWoHUmm_3xkRY7UzoXTuptKvUHzn0gK2WDiSa@mail.gmail.com> <201008302227.DJH30258.OQFMFtFJOOVSHL@I-love.SAKURA.ne.jp> <201009020633.DHJ01355.OQFMLtHSVOOJFF@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kosaki.motohiro@jp.fujitsu.com, spender@grsecurity.net,
	eric.dumazet@gmail.com
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201009020633.DHJ01355.OQFMLtHSVOOJFF@I-love.SAKURA.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2 Sep 2010, Tetsuo Handa wrote:

> Is it possible to make OOM killer to kill processes consuming kernel memory
> rather than userspace memory?
> 
> I'm happy if OOM killer can select victim process based on both kernel memory
> usage and userspace memory usage. For example, opening a file requires kernel
> memory allocation (e.g. /sys/kernel/security/tomoyo/self_domain allocates 8KB
> of kernel memory). Therefore, I refuse allowing everybody to open that file
> even if the content is public (because an attacker would open
> /sys/kernel/security/tomoyo/self_domain as many as possible using
> fork() and open() in order to exhaust kernel memory).

The oom killer has been rewritten for 2.6.36, so it'd probably help to 
frame it in the context of its new behavior, which you can try out in 
2.6.36-rc3.

The case you're describing would be difficult to kill with the oom killer 
because each fork() and exec() would be considered as seperate users of 
memory, so an aggregate of kernel memory amongst these threads wouldn't be 
considered.

The oom killer isn't really concerned whether the memory was allocated in 
userspace or kernelspace, the only thing that matters is that it's used 
and is unreclaimable (and non-migratable).

The memory controller accounts for user memory, so it's probably not a 
sufficient alternative either in this case.  Is it not possible for the 
kernel to intelligently limit the amount of memory that it can allocate 
through an interface at any given time?
