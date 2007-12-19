From: "Miles Lane" <miles.lane@gmail.com>
Subject: Re: 2.6.24-rc5-mm1 -- INFO: possible circular
	locking dependency detected -- pm-suspend/5800 is trying to
	acquire lock
Date: Wed, 19 Dec 2007 08:10:54 -0500
Message-ID: <a44ae5cd0712190510h72998e1dj5b03a00461a554f3@mail.gmail.com>
References: <a44ae5cd0712180603v2a37023dj714a8500c14c08de@mail.gmail.com>
	<1197986886.4885.156.camel@johannes.berg>
	<a44ae5cd0712180641n15ceae8bp977efe9a5b45e6bc@mail.gmail.com>
	<1197989826.4885.169.camel@johannes.berg>
	<1198033082.2857.303.camel@debian.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Len Brown <len.brown@intel.com>, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	ipw3945-devel@lists.sourceforge.net,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Pavel Machek <pavel@suse.cz>,
	Johannes Berg <johannes@sipsolutions.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: "Zhu Yi" <yi.zhu@intel.com>
Return-path: <ipw3945-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1198033082.2857.303.camel@debian.sh.intel.com>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ipw3945-devel>,
	<mailto:ipw3945-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=ipw3945-devel>
List-Post: <mailto:ipw3945-devel@lists.sourceforge.net>
List-Help: <mailto:ipw3945-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ipw3945-devel>,
	<mailto:ipw3945-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: ipw3945-devel-bounces@lists.sourceforge.net
Errors-To: ipw3945-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Dec 18, 2007 9:58 PM, Zhu Yi <yi.zhu@intel.com> wrote:
>
> On Tue, 2007-12-18 at 15:57 +0100, Johannes Berg wrote:
> > Thanks. This is a bug in iwlwifi.
> >
> > The problem is actually another case where my workqueue debugging with
> > lockdep is triggering a warning :))
> >
> > Here's the thing:
> >
> > iwl3945_cancel_deferred_work does
> >
> > cancel_delayed_work_sync(&priv->init_alive_start);
> >
> > (which is the "(&(&priv->init_alive_start)->work)" lock)
> >
> > but it is called from within a locked section of
> > mutex_lock(&priv->mutex); (locked from iwl3945_pci_suspend)
> >
> > On the other hand, the task that runs from the init_alive_start
> > workqueue is iwl3945_bg_init_alive_start() which will lock the same
> > mutex.
> >
> > So the deadlock condition is that you can be in
> > cancel_delayed_work_sync() above while the mutex is locked, and be
> > waiting for iwl_3945_bg_init_alive_start() which tries to lock the
> > mutex.
>
> Thanks for the analysis.
>
> Miles, please try the attached patch. I'll send a patch for both 3945
> and 4965 to linux-wireless later.

I tested it and it looks good here.  Thanks!

        Miles

-------------------------------------------------------------------------
SF.Net email is sponsored by:
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services
for just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
