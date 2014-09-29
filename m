From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v1 5/5] driver-core: add driver asynchronous probe support
Date: Mon, 29 Sep 2014 17:59:45 -0400
Message-ID: <20140929215945.GA1628@kroah.com>
References: <1411768637-6809-1-git-send-email-mcgrof@do-not-panic.com>
 <1411768637-6809-6-git-send-email-mcgrof@do-not-panic.com>
 <20140928150329.GC5023@mtj.dyndns.org>
 <20140929212208.GV17349@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <tj@kernel.org>,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	dmitry.torokhov@gmail.com, tiwai@suse.de, arjan@linux.intel.com,
	teg@jklm.no, rmilasan@suse.com, werner@suse.com, oleg@redhat.com,
	hare@suse.com, bpoirier@suse.de, santosh@chelsio.com,
	pmladek@suse.cz, dbueso@suse.com, linux-kernel@vger.kernel.org,
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
	Casey Leedom <leedom@chel
To: "Luis R. Rodriguez" <mcgrof@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140929212208.GV17349@wotan.suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 29, 2014 at 11:22:08PM +0200, Luis R. Rodriguez wrote:
> On Sun, Sep 28, 2014 at 11:03:29AM -0400, Tejun Heo wrote:
> > Hello,
> > 
> > On Fri, Sep 26, 2014 at 02:57:17PM -0700, Luis R. Rodriguez wrote:
> > ...
> > > Systemd should consider enabling async probe on device drivers
> > > it loads through systemd-udev but probably does not want to
> > > enable it for modules loaded through systemd-modules-load
> > > (modules-load.d). At least on my booting enablign async probe
> > > for all modules fails to boot as such in order to make this
> > 
> > Did you find out why boot failed with those modules?
> 
> No, it seems this was early in boot and I haven't been able to capture the logs
> yet of the faults. More on this below.
> 
> > > a bit more useful we whitelist a few buses where it should be
> > > at least in theory safe to try to enable async probe. This
> > > way even if systemd tried to ask to enable async probe for all
> > > its device drivers the kernel won't blindly do this. We also
> > > have the sync_probe flag which device drivers can themselves
> > > enable *iff* its known the device driver should never async
> > > probe.
> > > 
> > > In order to help *test* things folks can use the bus.safe_mod_async_probe=1
> > > kernel parameter which will work as if userspace would have
> > > requested all modules to load with async probe. Daring folks can
> > > also use bus.force_mod_async_probe=1 which will enable asynch probe
> > > even on buses not tested in any way yet, if you use that though
> > > you're on your own.
> > 
> > If those two knobs are meant for debugging, let's please make that
> > fact immediately evident.  e.g. Make them ugly boot params like
> > "__DEVEL__driver_force_mod_async_probe".  Devel/debug options ending
> > up becoming stable interface are really nasty.
> 
> Sure make sense, I wasn't quite sure how to make this quite clear,
> a naming convention seems good to me but I also had added at least
> a print about this on the log. Ideally I think a TAIN_DEBUG would
> be best and it seems it could be useful for many other cases in
> the kernel, we could also just re-use TAINT_CRAP as well. Thoughts?
> Greg?

TAINT_CRAP is for drivers/staging/ code, don't try to repurpose it for
some other horrid option.  There's no reason we can't add more taint
flags for this.

greg k-h
