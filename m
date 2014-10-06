From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: [PATCH v2 7/7] driver-core: add preferred async probe option
	for built-in and modules
Date: Tue, 7 Oct 2014 01:10:46 +0200
Message-ID: <20141006231046.GD14081@wotan.suse.de>
References: <1412372683-2003-1-git-send-email-mcgrof@do-not-panic.com> <1412372683-2003-8-git-send-email-mcgrof@do-not-panic.com> <20141006201926.GF18303@htj.dyndns.org> <20141006203627.GZ14081@wotan.suse.de> <20141006210118.GG18303@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	gregkh@linuxfoundation.org, dmitry.torokhov@gmail.com,
	tiwai@suse.de, arjan@linux.intel.com, teg@jklm.no,
	rmilasan@suse.com, werner@suse.com, oleg@redhat.com, hare@suse.com,
	bpoirier@suse.de, santosh@chelsio.com, pmladek@suse.cz,
	dbueso@suse.com, linux-kernel@vger.kernel.org,
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
	Casey Leedom <leedom@che
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141006210118.GG18303@htj.dyndns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 06, 2014 at 05:01:18PM -0400, Tejun Heo wrote:
> Hello,
> 
> On Mon, Oct 06, 2014 at 10:36:27PM +0200, Luis R. Rodriguez wrote:
> > > Do we intend to keep this param permanently?  Isn't this more of a
> > > temp tool to be used during development?  If so, maybe we should make
> > > that clear with __DEVEL__ too?
> > 
> > As its designed right now no, its not a temp tool, its there to
> > require compatibility with old userspace. For modules we can require
> > the module parameter but for built-in we need something else and this
> > is what came to mind. It is also what would allow the prefer_async_probe
> > flag too as otherwise we won't know if userspace is prepared.
> 
> I don't get it. 

By prepared I meant that userspace can handle async probe, but
you're right that we don't need to know that. I don't see how
we'd be breaking old userspace by doing async probe of a driver
is built-in right now... unless of course built-in always assumes
all possible devices would be present after right before userspace
init.

> For in-kernel stuff, we already have a clear
> synchronization point where we already synchronize all async calls.
> Shouldn't we be flushing these async probes there too?

This seems to be addressing if what I meant by prepared, "ready", so let
me address this as I do think its important.

By async calls do you mean users of async_schedule()? I see it
also uses system_unbound_wq as well but I do not see anyone calling
flush_workqueue(system_unbound_wq) on the kernel. We do use
async_synchronize_full() on kernel_init() but that just waits.

As it is we don't wait on init then, should we? Must we? Could / should
we use bus.enable_kern_async=1 to enable avoiding having to wait ? At
this point I'd prefer to address what we must do only.

> insmod'ing is
> userland visible but there's no reason this has to be for the built-in
> drivers.

Good point.

bus.enable_kern_async=1 would still also serve as a helper for the driver core
to figure out if it should use async probe then on modules if prefer_async_probe
was enabled. Let me know if you figure out a way to avoid it.

  Luis
