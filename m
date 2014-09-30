From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: [PATCH v1 5/5] driver-core: add driver asynchronous probe
	support
Date: Tue, 30 Sep 2014 09:15:55 +0200
Message-ID: <20140930071555.GB14081@wotan.suse.de>
References: <1411768637-6809-1-git-send-email-mcgrof@do-not-panic.com> <1411768637-6809-6-git-send-email-mcgrof@do-not-panic.com> <20140928192247.GA28033@core.coreip.homeip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	gregkh@linuxfoundation.org, tiwai@suse.de, tj@kernel.org,
	arjan@linux.intel.com, teg@jklm.no, rmilasan@suse.com,
	werner@suse.com, oleg@redhat.com, hare@suse.com, bpoirier@suse.de,
	santosh@chelsio.com, pmladek@suse.cz, dbueso@suse.com,
	linux-kernel@vger.kernel.org,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	Joseph Salisbury <joseph.salisbury@canonical.com>,
	Kay Sievers <kay@vrfy.org>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
	Sreekanth Reddy <sreekanth.reddy@avagotech.com>,
	Abhijit Mahajan <abhijit.mahajan@avagotech.com>,
	Casey Leedom <leedom@chelsio.com>,
To: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140928192247.GA28033@core.coreip.homeip.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 28, 2014 at 12:22:47PM -0700, Dmitry Torokhov wrote:
> Hi Luis,
> 
> On Fri, Sep 26, 2014 at 02:57:17PM -0700, Luis R. Rodriguez wrote:
> > +static bool drv_enable_async_probe(struct device_driver *drv,
> > +				   struct bus_type *bus)
> > +{
> > +	struct module *mod;
> > +
> > +	if (!drv->owner || drv->sync_probe)
> > +		return false;
> 
> This bit is one of the biggest issues I have with the patch set. Why async
> probing is limited to modules only?

Because Tejun wanted to address this separately, so its not that we will restrict
this but we should have non-module solution added as an evolution on top of this,
as a secondary step.

> I mentioned several times that we need
> async probing for built-in drivers and the way you are structuring the flags
> (async by default for modules, possibly opt-out of async for modules, forcibly
> sync for built-in) it is hard to extend the infrastructure for built-in case.

I confess I haven't tried enabling built-in as a secondary step but its just
due to lack of time right now but I don't think impossible and think actually
think it should be fairly trivial. Are there real blockers to do this that
you see as an evolutionary step?

> Also, as far as I can see, you are only considering the case where driver is
> being bound to already registered devices. If you have a module that creates a
> device for a driver that is already loaded and takes long time to probe you
> would still be probing synchronously even if driver/module requested async
> behavior.

Can you provide an example code path hit here? I'll certainly like to address
that as well.

  Luis
