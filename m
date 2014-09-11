From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: Re: [RFC v2 3/6] kthread: warn on kill signal if not OOM
Date: Thu, 11 Sep 2014 13:23:54 -0700
Message-ID: <20140911202354.GA2598@core.coreip.homeip.net>
References: <20140905174925.GA12991@mtj.dyndns.org>
 <20140909224143.GB3154@mtj.dyndns.org>
 <1410302783.13298.50.camel@jarvis.lan>
 <5762134.BLS0EbmNJd@dtor-glaptop>
 <1410465565.10549.19.camel@jarvis>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <tj@kernel.org>,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	Lennart Poettering <lennart@poettering.net>,
	Kay Sievers <kay@vrfy.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Wu Zhangjin <falcon@meizu.com>, Takashi Iwai <tiwai@suse.de>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Oleg Nesterov <oleg@redhat.com>, hare@suse.com,
	Andrew Morton <akpm@linux-foundation.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Joseph Salisbury <joseph.salisbury@canonical.com>,
	Benjamin Poirier <bpoirier@suse.de>,
	Santosh Rastapur <santosh@chelsio.com>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnamoorthy <praveen.krishnamoorthy@a
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1410465565.10549.19.camel@jarvis>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 11, 2014 at 12:59:25PM -0700, James Bottomley wrote:
> 
> On Tue, 2014-09-09 at 16:01 -0700, Dmitry Torokhov wrote:
> > On Tuesday, September 09, 2014 03:46:23 PM James Bottomley wrote:
> > > On Wed, 2014-09-10 at 07:41 +0900, Tejun Heo wrote:
> > > > 
> > > > The thing is that we have to have dynamic mechanism to listen for
> > > > device attachments no matter what and such mechanism has been in place
> > > > for a long time at this point.  The synchronous wait simply doesn't
> > > > serve any purpose anymore and kinda gets in the way in that it makes
> > > > it a possibly extremely slow process to tell whether loading of a
> > > > module succeeded or not because the wait for the initial round of
> > > > probe is piggybacked.
> > > 
> > > OK, so we just fire and forget in userland ... why bother inventing an
> > > elaborate new infrastructure in the kernel to do exactly what
> > > 
> > > modprobe <mod> &
> > > 
> > > would do?
> > 
> > Just so we do not forget: we also want the no-modules case to also be able
> > to probe asynchronously so that a slow device does not stall kernel booting.
> 
> Yes, but we mostly do this anyway.  SCSI for instance does asynchronous
> scanning of attached devices (once the cards are probed)

What would it do it card was a bit slow to probe?

> but has a sync
> point for ordering.

Quite often we do not really care about ordering of devices. I mean,
does it matter if your mouse is discovered before your keyboard or
after?

>
> The problem of speeding up boot is different from the one of init
> processes killing modprobes.

Right. One is systemd doing stupid things, another is kernel could be
smarter.

>  There are elements in common, but by and
> large the biggest headaches at least in large device number boots have
> already been tackled by the enterprise crowd (they don't like their
> S390's or 1024 core NUMA systems taking half an hour to come up).

Please do not position this as a mostly solved large systems problem,
For us it is touchpad detection stalling kernel for 0.5-1 sec. Which is
a lot given that we boot in seconds.

Thanks.

-- 
Dmitry
