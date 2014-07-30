From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v2 2/4] driver core: enable drivers to use deferred probe
 from init
Date: Tue, 29 Jul 2014 17:13:20 -0700
Message-ID: <20140730001320.GA32364@kroah.com>
References: <1406572110-26823-3-git-send-email-mcgrof@do-not-panic.com>
 <20140728185538.GB17609@kroah.com>
 <CAB=NE6VebcR7=UA1n0wNVLr5FFukzq6aW5CkeB3nf5FixV=3cA@mail.gmail.com>
 <CAB=NE6Xmi2zUCis22q+X8_AKRcwMrAtmx-aqSSvTB70Xjet6VQ@mail.gmail.com>
 <20140728234644.GA18729@kroah.com>
 <CAB=NE6UzK1ZEzm+54dwSyPwHGrAWCPtiNtxwhQuJF6tM9NbnYw@mail.gmail.com>
 <20140729003501.GA17020@kroah.com>
 <CAB=NE6XMzU+zJ0RMDKaPuSxfXBvN2vZ1DnbgxCjWHJquTD1iqg@mail.gmail.com>
 <20140729231422.GA14494@kroah.com>
 <20140730000541.GR21930@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Santosh Rastapur <santosh@chelsio.com>,
	Hariprasad S <hariprasad@chelsio.com>,
	Takashi Iwai <tiwai@suse.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Joseph Salisbury <joseph.salisbury@canonical.com>,
	Kay Sievers <kay@vrfy.org>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Benjamin Poirier <bpoirier@suse.de>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
	Sreekanth Reddy <sreekanth.reddy@avagotech.com>,
	Abhijit Mahajan <abhijit.mahajan@avagotech.com>,
	MPT-FusionLinux.pdl@avagotech.com,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	"netdev@vger.kernel.org
To: "Luis R. Rodriguez" <mcgrof@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140730000541.GR21930@wotan.suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 30, 2014 at 02:05:41AM +0200, Luis R. Rodriguez wrote:
> On Tue, Jul 29, 2014 at 04:14:22PM -0700, Greg KH wrote:
> > On Mon, Jul 28, 2014 at 06:13:43PM -0700, Luis R. Rodriguez wrote:
> > > >> > Why not just put the initial "register the device" in a single-shot
> > > >> > workqueue or thread or something like that so that modprobe returns
> > > >> > instantly back with a success and all is fine?
> > > >>
> > > >> That surely is possible but why not a general solution for such kludges?
> > > >
> > > > Because the driver should be fixed.  How hard would it be to do what I
> > > > just suggested here, 20 lines added at most?
> > > 
> > > I appreciate the feedback, but don't look at me, I'd happy to go nutty
> > > on ripping things apart from hairy drivers, however Chelsie folks
> > > expressed concerns over major rework on the driver... so even if we
> > > did have something I expect things to take a while to bake / gain
> > > confidence from others.
> > 
> > "rework"?  Heh, here's a patch that adds 10 lines to the mptsas driver
> > that should also work for any other driver as well.  Why not just do
> > this instead?
> 
> That's not a rework, that's a kludge, doing something similar for other
> drivers would be replicating kludges, the deferred probe use was trying
> to generalize a kludge with 3 lines of code. But I'm no not yet convinced
> its the best solution now.

I'm not saying it's pretty, but it confied to just the broken module,
and also, it's obvious what needs to be fixed if someone cares.

It sounds like no one cares about these moduls :)

Adding it to the driver core ensures that the drivers will _never_ be
changed, which isn't ok with me, sorry.


> > > This also just addresses this *one* Ethernet driver, there was that
> > > SCSI driver that created the original report -- Canonical merged
> > > Joseph's fix as a work around,
> > 
> > What fix was that?
> 
> https://launchpadlibrarian.net/169714201/kthread-Do-not-leave-kthread_create-immediately.patch
> 
> It was reviewed and Oleg preferred the timeout instead be reviewed
> on systemd devel mailing list. That didn't go anywhere but today Hannes
> posted a patch and that got merged. Its still not solving all issues
> though as it lets us override the timeout value, systems / drivers
> can still crash without a long timeout.

Great, work it out with them, again, stay away from the driver core for
this...

> > > there is no general solution for this yet, and again with that work
> > > around you won't find which drivers run into this issue.
> > 
> > Great, fix them as they are found, that's fine. 
> 
> Are we really OK in letting distributions have to deal with crashes
> because of this new driver 30 second timeout ?

If you don't want to, then revert the kernel change that caused it for
your distro kernels.

> I think warning about it would be better and more friendlier, no? What
> gains do we have to kill the damn thing?

Take it up with the owners of that code...

> > Again, don't add stuff
> > to the driver core to paper over crappy drivers, I'm not going to take
> > that type of change.  I _only_ took the defer binding code as there was
> > no other way for an individual driver to deal with things if it's
> > resources were not present yet due to binding order in the system.
> 
> Ok but its a bit unfair to force killing drivers over a new driver 30 second
> timeout requirement for a change that was made implicitly through a series
> of collateral changes.

I'm not disagreeing with that, but hey, life isn't fair, and things
needs to get fixed all the time...

I say fix it _properly_ by fixing the drivers.

best of luck,

greg k-h
