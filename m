From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Block device throttling [Re: Distributed storage.]
Date: Tue, 14 Aug 2007 12:46:25 +0400
Message-ID: <20070814084625.GA20265@2ka.mipt.ru>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708130418.03667.phillips@phunq.net> <20070813121802.GB5992@2ka.mipt.ru> <200708130604.07154.phillips@phunq.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <jens.axboe@oracle.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Daniel Phillips <phillips@phunq.net>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200708130604.07154.phillips@phunq.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 13, 2007 at 06:04:06AM -0700, Daniel Phillips (phillips@phunq.net) wrote:
> Perhaps you never worried about the resources that the device mapper 
> mapping function allocates to handle each bio and so did not consider 
> this hole significant.  These resources can be significant, as is the 
> case with ddsnap.  It is essential to close that window through with 
> the virtual device's queue limit may be violated.  Not doing so will 
> allow deadlock.

This is not a bug, this is special kind of calculation - total limit is
number of physical devices multiplied by theirs limits. It was done 
_on purpose_ to allow different device to have different limits (for 
example in distributed storage project it is possible to have both remote 
and local node in the same device, but local device should not have _any_
limit at all, but network one should).

Virtual device essentially has _no_ limit. And that as done on purpose.

-- 
	Evgeniy Polyakov
