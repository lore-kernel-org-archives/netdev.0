From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: Re: [RFC v2 3/6] kthread: warn on kill signal if not OOM
Date: Mon, 22 Sep 2014 13:23:54 -0700
Message-ID: <2306678.TJaWkZCAc8@dtor-glaptop>
References: <20140905174925.GA12991@mtj.dyndns.org> <20140911202354.GA2598@core.coreip.homeip.net> <20140922194906.GB9868@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>,
	Tejun Heo <tj@kernel.org>,
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
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagote
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140922194906.GB9868@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, September 22, 2014 09:49:06 PM Pavel Machek wrote:
> On Thu 2014-09-11 13:23:54, Dmitry Torokhov wrote:
> > On Thu, Sep 11, 2014 at 12:59:25PM -0700, James Bottomley wrote:
> > > On Tue, 2014-09-09 at 16:01 -0700, Dmitry Torokhov wrote:
> > > > On Tuesday, September 09, 2014 03:46:23 PM James Bottomley wrote:
> > > > > On Wed, 2014-09-10 at 07:41 +0900, Tejun Heo wrote:
> > > > > > The thing is that we have to have dynamic mechanism to listen for
> > > > > > device attachments no matter what and such mechanism has been in
> > > > > > place
> > > > > > for a long time at this point.  The synchronous wait simply
> > > > > > doesn't
> > > > > > serve any purpose anymore and kinda gets in the way in that it
> > > > > > makes
> > > > > > it a possibly extremely slow process to tell whether loading of a
> > > > > > module succeeded or not because the wait for the initial round of
> > > > > > probe is piggybacked.
> > > > > 
> > > > > OK, so we just fire and forget in userland ... why bother inventing
> > > > > an
> > > > > elaborate new infrastructure in the kernel to do exactly what
> > > > > 
> > > > > modprobe <mod> &
> > > > > 
> > > > > would do?
> > > > 
> > > > Just so we do not forget: we also want the no-modules case to also be
> > > > able
> > > > to probe asynchronously so that a slow device does not stall kernel
> > > > booting.> > 
> > > Yes, but we mostly do this anyway.  SCSI for instance does asynchronous
> > > scanning of attached devices (once the cards are probed)
> > 
> > What would it do it card was a bit slow to probe?
> > 
> > > but has a sync
> > > point for ordering.
> > 
> > Quite often we do not really care about ordering of devices. I mean,
> > does it matter if your mouse is discovered before your keyboard or
> > after?
> 
> Actually yes, I suspect it does.
> 
> I do evtest /dev/input/eventX by hand, occassionaly. It would be
> annoying if they moved between reboots.

I am sorry but you will have to cope with such annoyances. It' snot like we 
fail to boot the box here.

The systems are now mostly hot-pluggable and userland is supposed to
handle it, and it does, at least for input devices. If you want stable naming
use udev facilities to rename devices as needed or add needed symlinks (by-id, 
etc.).

Thanks.

-- 
Dmitry
