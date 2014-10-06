From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: [PATCH v2 7/7] driver-core: add preferred async probe option
	for built-in and modules
Date: Mon, 6 Oct 2014 22:36:27 +0200
Message-ID: <20141006203627.GZ14081@wotan.suse.de>
References: <1412372683-2003-1-git-send-email-mcgrof@do-not-panic.com> <1412372683-2003-8-git-send-email-mcgrof@do-not-panic.com> <20141006201926.GF18303@htj.dyndns.org>
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
In-Reply-To: <20141006201926.GF18303@htj.dyndns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 06, 2014 at 04:19:26PM -0400, Tejun Heo wrote:
> Hello, Luis.
> 
> The patchset generally looks good to me.  Please feel free to add
> 
>  Reviewed-by: Tejun Heo <tj@kernel.org>

Will do.

> A question below.
> 
> On Fri, Oct 03, 2014 at 02:44:43PM -0700, Luis R. Rodriguez wrote:
> > +	bus.enable_kern_async=1 [KNL]
> > +			This tells the kernel userspace has been vetted for
> > +			asynchronous probe support and can listen to the device
> > +			driver prefer_async_probe flag for both built-in device
> > +			drivers and modules.
> 
> Do we intend to keep this param permanently?  Isn't this more of a
> temp tool to be used during development?  If so, maybe we should make
> that clear with __DEVEL__ too?

As its designed right now no, its not a temp tool, its there to
require compatibility with old userspace. For modules we can require
the module parameter but for built-in we need something else and this
is what came to mind. It is also what would allow the prefer_async_probe
flag too as otherwise we won't know if userspace is prepared.

If we want to get rid of it, it would mean that we're letting go of the idea
that some userspace might exist which depends on *not* doing async probe. As
such I would not consider it a __DEVEL__ param and it'd be a judgement call
to eventually *not require* it. I can see that happening but perhaps a large
series of kernels down the road?

  Luis
