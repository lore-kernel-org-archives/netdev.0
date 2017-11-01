From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the tip tree
Date: Wed, 1 Nov 2017 21:51:50 +1100
Message-ID: <20171101215150.74daafd2@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Kees Cook <keescook@chromium.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
        "H. Peter Anvin" <hpa@zytor.com>,
        Peter Zijlstra <peterz@infradead.org>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

After merging the tip tree, today's linux-next build (x86_64 allmodconfig)
failed like this:

In file included from include/linux/workqueue.h:8:0,
                 from include/linux/srcu.h:34,
                 from include/linux/notifier.h:15,
                 from include/linux/memory_hotplug.h:6,
                 from include/linux/mmzone.h:779,
                 from include/linux/gfp.h:5,
                 from include/linux/umh.h:4,
                 from include/linux/kmod.h:22,
                 from include/linux/module.h:13,
                 from drivers/net/ethernet/chelsio/cxgb/common.h:43,
                 from drivers/net/ethernet/chelsio/cxgb/sge.c:39:
drivers/net/ethernet/chelsio/cxgb/sge.c: In function 't1_sge_create':
include/linux/timer.h:176:24: warning: cast to pointer from integer of different size [-Wint-to-pointer-cast]
   __setup_timer(timer, (TIMER_FUNC_TYPE)callback,  \
                        ^
include/linux/timer.h:122:25: note: in definition of macro '__setup_timer'
   (_timer)->function = (_fn);    \
                         ^
drivers/net/ethernet/chelsio/cxgb/sge.c:2081:3: note: in expansion of macro 'timer_setup'
   timer_setup(&sge->espibug_timer,
   ^
drivers/net/ethernet/chelsio/cxgb/sge.c:2082:31: warning: comparison between pointer and integer
        adapter->params.nports > 1 ? espibug_workaround_t204 : espibug_workaround,
                               ^
include/linux/timer.h:122:25: note: in definition of macro '__setup_timer'
   (_timer)->function = (_fn);    \
                         ^
drivers/net/ethernet/chelsio/cxgb/sge.c:2081:3: note: in expansion of macro 'timer_setup'
   timer_setup(&sge->espibug_timer,
   ^
include/linux/timer.h:122:22: error: assignment from incompatible pointer type [-Werror=incompatible-pointer-types]
   (_timer)->function = (_fn);    \
                      ^
include/linux/timer.h:176:3: note: in expansion of macro '__setup_timer'
   __setup_timer(timer, (TIMER_FUNC_TYPE)callback,  \
   ^
drivers/net/ethernet/chelsio/cxgb/sge.c:2081:3: note: in expansion of macro 'timer_setup'
   timer_setup(&sge->espibug_timer,
   ^

and another similar.

Caused by commit

  cacd2b3fb981 ("chelsio: Convert timers to use timer_setup()")

from te net-next tree interacting with commit

  52f737c2da40 ("timer: Provide wrappers safe for use with LOCKDEP")

from the tip tree.

Looks like the LOCKDEP sage version of timer_setup() needs to put
parentheses around the usages of its parameters?

-- 
Cheers,
Stephen Rothwell
