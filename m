From: Daniel Phillips <phillips@phunq.net>
Subject: Re: Block device throttling [Re: Distributed storage.]
Date: Tue, 14 Aug 2007 04:13:10 -0700
Message-ID: <200708140413.12530.phillips@phunq.net>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708130604.07154.phillips@phunq.net> <20070814084625.GA20265@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jens Axboe <jens.axboe@oracle.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070814084625.GA20265@2ka.mipt.ru>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 14 August 2007 01:46, Evgeniy Polyakov wrote:
> On Mon, Aug 13, 2007 at 06:04:06AM -0700, Daniel Phillips 
(phillips@phunq.net) wrote:
> > Perhaps you never worried about the resources that the device
> > mapper mapping function allocates to handle each bio and so did not
> > consider this hole significant.  These resources can be
> > significant, as is the case with ddsnap.  It is essential to close
> > that window through with the virtual device's queue limit may be
> > violated.  Not doing so will allow deadlock.
>
> This is not a bug, this is special kind of calculation - total limit
> is number of physical devices multiplied by theirs limits. It was
> done _on purpose_ to allow different device to have different limits
> (for example in distributed storage project it is possible to have
> both remote and local node in the same device, but local device
> should not have _any_ limit at all, but network one should).
>
> Virtual device essentially has _no_ limit. And that as done on
> purpose.

And it will not solve the deadlock problem in general.  (Maybe it works 
for your virtual device, but I wonder...)  If the virtual device 
allocates memory during generic_make_request then the memory needs to 
be throttled.

Regards,

Daniel
