From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: [PATCH v2 7/7] driver-core: add preferred async probe option
	for built-in and modules
Date: Tue, 7 Oct 2014 19:50:10 +0200
Message-ID: <20141007175010.GH14081@wotan.suse.de>
References: <1412372683-2003-1-git-send-email-mcgrof@do-not-panic.com> <1412372683-2003-8-git-send-email-mcgrof@do-not-panic.com> <20141006201926.GF18303@htj.dyndns.org> <20141006203627.GZ14081@wotan.suse.de> <20141006210118.GG18303@htj.dyndns.org> <20141006231046.GD14081@wotan.suse.de> <20141007173404.GB31328@mtj.dyndns.org>
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
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141007173404.GB31328@mtj.dyndns.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 07, 2014 at 01:34:04PM -0400, Tejun Heo wrote:
> Hello,
> 
> On Tue, Oct 07, 2014 at 01:10:46AM +0200, Luis R. Rodriguez wrote:
> > On Mon, Oct 06, 2014 at 05:01:18PM -0400, Tejun Heo wrote:
> > > For in-kernel stuff, we already have a clear
> > > synchronization point where we already synchronize all async calls.
> > > Shouldn't we be flushing these async probes there too?
> > 
> > This seems to be addressing if what I meant by prepared, "ready", so let
> > me address this as I do think its important.
> > 
> > By async calls do you mean users of async_schedule()? I see it
> 
> Yes.
> 
> > also uses system_unbound_wq as well but I do not see anyone calling
> > flush_workqueue(system_unbound_wq) on the kernel. We do use
> > async_synchronize_full() on kernel_init() but that just waits.
> 
> But you can create a new workqueue and queue all the async probing
> work items there and flush the workqueue right after
> async_synchronize_full().

On second thought I would prefer to avoid this, I see this being good
to help with old userspace but other than that I don't see a requirement
for new userspace. Do you?

> ...
> > bus.enable_kern_async=1 would still also serve as a helper for the driver core
> > to figure out if it should use async probe then on modules if prefer_async_probe
> > was enabled. Let me know if you figure out a way to avoid it.
> 
> Why do we need the choice at all?  It always should, no?

I'm OK to live with that, in that case I see no point to bus.enable_kern_async=1
at all.

  Luis
