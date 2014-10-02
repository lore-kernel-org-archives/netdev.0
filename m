From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: [PATCH v1 5/5] driver-core: add driver asynchronous probe
	support
Date: Fri, 3 Oct 2014 01:29:44 +0200
Message-ID: <20141002232944.GT14081@wotan.suse.de>
References: <1411768637-6809-1-git-send-email-mcgrof@do-not-panic.com> <1411768637-6809-6-git-send-email-mcgrof@do-not-panic.com> <20140928150329.GC5023@mtj.dyndns.org> <20140929212208.GV17349@wotan.suse.de> <20140929212601.GF15925@htj.dyndns.org> <20140930072159.GC14081@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gregkh@linuxfoundation.org,
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
	Casey Leedom <leedom@che
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140930072159.GC14081@wotan.suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 30, 2014 at 09:21:59AM +0200, Luis R. Rodriguez wrote:
> On Mon, Sep 29, 2014 at 05:26:01PM -0400, Tejun Heo wrote:
> > Hello, Luis.
> > 
> > On Mon, Sep 29, 2014 at 11:22:08PM +0200, Luis R. Rodriguez wrote:
> > > > > +	/* For now lets avoid stupid bug reports */
> > > > > +	if (!strcmp(bus->name, "pci") ||
> > > > > +	    !strcmp(bus->name, "pci_express") ||
> > > > > +	    !strcmp(bus->name, "hid") ||
> > > > > +	    !strcmp(bus->name, "sdio") ||
> > > > > +	    !strcmp(bus->name, "gameport") ||
> > > > > +	    !strcmp(bus->name, "mmc") ||
> > > > > +	    !strcmp(bus->name, "i2c") ||
> > > > > +	    !strcmp(bus->name, "platform") ||
> > > > > +	    !strcmp(bus->name, "usb"))
> > > > > +		return true;
> > > > 
> > > > Ugh... things like this tend to become permanent.  Do we really need
> > > > this?  And how are we gonna find out what's broken why w/o bug
> > > > reports?
> > > 
> > > Yeah... well we have two options, one is have something like this to
> > > at least make it generally useful or remove this and let folks who
> > > care start fixing async for all modules. The downside to removing
> > > this is it makes async probe pretty much useless on most systems
> > > right now, it would mean systemd would have to probably consider
> > > the list above if they wanted to start using this without expecting
> > > systems to not work.
> > 
> > So, I'd much prefer blacklist approach if something like this is a
> > necessity.  That way, we'd at least know what doesn't work.
> 
> For buses? Or do you mean you'd want to wait until we have a decent
> list of drivers with the sync probe flag set? If the later it may take
> a while to get that list for this to be somewhat useful.

OK I'm removing this part and it works well for me now on my laptop
and an AMD server without a white list, so all the junk above will
be removed in the next series.

  Luis
