From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mmotm 2010-07-19 - e1000e vs.
	pm_qos_update_request issues
Date: Tue, 20 Jul 2010 14:07:51 -0700
Message-ID: <20100720140751.71ee83a8.akpm@linux-foundation.org>
References: <201007200007.o6K07Xbg028863@imap1.linux-foundation.org>
	<6182.1279658125@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, mark gross <markgross@thegnar.org>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>
To: Valdis.Kletnieks@vt.edu
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <6182.1279658125@localhost>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, 20 Jul 2010 16:35:25 -0400
Valdis.Kletnieks@vt.edu wrote:

> On Mon, 19 Jul 2010 16:38:09 PDT, akpm@linux-foundation.org said:
> > The mm-of-the-moment snapshot 2010-07-19-16-37 has been uploaded to
> > 
> >    http://userweb.kernel.org/~akpm/mmotm/
> 
> Throws a warning at boot:
> 
> [    1.786060] WARNING: at kernel/pm_qos_params.c:264 pm_qos_update_request+0x28/0x54()
> [    1.786088] Hardware name: Latitude E6500
> [    1.787045] pm_qos_update_request() called for unknown object
> [    1.787966] Modules linked in:
> [    1.788940] Pid: 1, comm: swapper Not tainted 2.6.35-rc5-mmotm0719 #1
> [    1.790035] Call Trace:
> [    1.791121]  [<ffffffff81037335>] warn_slowpath_common+0x80/0x98
> [    1.792205]  [<ffffffff810373e1>] warn_slowpath_fmt+0x41/0x43
> [    1.793279]  [<ffffffff81057c14>] pm_qos_update_request+0x28/0x54
> [    1.794347]  [<ffffffff8134889e>] e1000_configure+0x421/0x459
> [    1.795393]  [<ffffffff8134afbd>] e1000_open+0xbd/0x37c
> [    1.796436]  [<ffffffff8105743a>] ? raw_notifier_call_chain+0xf/0x11
> [    1.797491]  [<ffffffff8145f948>] __dev_open+0xae/0xe2
> [    1.798547]  [<ffffffff8145f997>] dev_open+0x1b/0x49
> [    1.799612]  [<ffffffff8146e36e>] netpoll_setup+0x84/0x259
> [    1.800685]  [<ffffffff81b5037c>] init_netconsole+0xbc/0x21f
> [    1.801744]  [<ffffffff81b5026c>] ? sir_wq_init+0x0/0x35
> [    1.802793]  [<ffffffff81b502c0>] ? init_netconsole+0x0/0x21f
> [    1.803845]  [<ffffffff810002ff>] do_one_initcall+0x7a/0x12f
> [    1.804885]  [<ffffffff81b2ccae>] kernel_init+0x138/0x1c2
> [    1.805915]  [<ffffffff81003554>] kernel_thread_helper+0x4/0x10
> [    1.806937]  [<ffffffff81590e00>] ? restore_args+0x0/0x30
> [    1.807955]  [<ffffffff81b2cb76>] ? kernel_init+0x0/0x1c2
> [    1.808958]  [<ffffffff81003550>] ? kernel_thread_helper+0x0/0x10
> [    1.809958] ---[ end trace 84b562a00a60539e ]---
> 
> Looks like a repeat of something I reported against -mmotm 2010-05-11, though a
> WARNING rather than an outright crash - the traceback is pretty much identical.
>  I have *no* idea why -rc3-mmotm0701 doesn't whinge similarly.
> 

I don't recall you reporting that, sorry.

The warning was added by

: commit 82f682514a5df89ffb3890627eebf0897b7a84ec
: Author:     James Bottomley <James.Bottomley@suse.de>
: AuthorDate: Mon Jul 5 22:53:06 2010 +0200
: Commit:     Rafael J. Wysocki <rjw@sisk.pl>
: CommitDate: Mon Jul 19 02:00:34 2010 +0200
: 
:     pm_qos: Get rid of the allocation in pm_qos_add_request()


It's a pretty crappy warning too.  Neither the warning nor the code
comments provide developers with any hint as to what they have done
wrong, nor what they must do to fix things.  And the patch changelog
doesn't mention the new warnings *at all*.

So one must assume that the people who stuck this thing in the tree
have volunteered to fix e1000e.  Let's cc 'em.


------------------------------------------------------------------------------
This SF.net email is sponsored by Sprint
What will you do first with EVO, the first 4G phone?
Visit sprint.com/first -- http://p.sf.net/sfu/sprint-com-first
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
