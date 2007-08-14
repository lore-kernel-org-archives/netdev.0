From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Block device throttling [Re: Distributed storage.]
Date: Tue, 14 Aug 2007 15:30:42 +0400
Message-ID: <20070814113039.GA20780@2ka.mipt.ru>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708130604.07154.phillips@phunq.net> <20070814084625.GA20265@2ka.mipt.ru> <200708140413.12530.phillips@phunq.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <jens.axboe@oracle.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Daniel Phillips <phillips@phunq.net>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200708140413.12530.phillips@phunq.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 14, 2007 at 04:13:10AM -0700, Daniel Phillips (phillips@phunq.net) wrote:
> On Tuesday 14 August 2007 01:46, Evgeniy Polyakov wrote:
> > On Mon, Aug 13, 2007 at 06:04:06AM -0700, Daniel Phillips 
> (phillips@phunq.net) wrote:
> > > Perhaps you never worried about the resources that the device
> > > mapper mapping function allocates to handle each bio and so did not
> > > consider this hole significant.  These resources can be
> > > significant, as is the case with ddsnap.  It is essential to close
> > > that window through with the virtual device's queue limit may be
> > > violated.  Not doing so will allow deadlock.
> >
> > This is not a bug, this is special kind of calculation - total limit
> > is number of physical devices multiplied by theirs limits. It was
> > done _on purpose_ to allow different device to have different limits
> > (for example in distributed storage project it is possible to have
> > both remote and local node in the same device, but local device
> > should not have _any_ limit at all, but network one should).
> >
> > Virtual device essentially has _no_ limit. And that as done on
> > purpose.
> 
> And it will not solve the deadlock problem in general.  (Maybe it works 
> for your virtual device, but I wonder...)  If the virtual device 
> allocates memory during generic_make_request then the memory needs to 
> be throttled.

Daniel, if device process bio by itself, it has a limit and thus it will
wait in generic_make_request(), if it queues it to different device,
then the same logic applies there. If virutal device does not process
bio, its limit will always be recharged to underlying devices, and
overall limit is equal to number of physical device (or devices which do
process bio) multiplied by theirs limits. This does _work_ and I showed
example how limits are processed and who and where will sleep. This
solution is not narrow fix, please check my examples I showed before.

> Regards,
> 
> Daniel

-- 
	Evgeniy Polyakov
