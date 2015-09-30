From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 02/23] usb-gadget: use per-attribute show and store
 methods
Date: Wed, 30 Sep 2015 12:59:34 -0400
Message-ID: <20150930165934.GD2627@mtj.duckdns.org>
References: <1443189000-13398-1-git-send-email-hch@lst.de>
 <1443189000-13398-3-git-send-email-hch@lst.de>
 <20150927155053.GD16364@saruman.tx.rr.com>
 <20150928133514.GB30453@lst.de>
 <20150930161925.GJ32625@saruman.tx.rr.com>
 <20150930162046.GB2627@mtj.duckdns.org>
 <20150930163219.GN32625@saruman.tx.rr.com>
 <20150930163538.GC2627@mtj.duckdns.org>
 <20150930164301.GP32625@saruman.tx.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@lst.de>, Joel Becker <jlbec@evilplan.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pratyush Anand <pratyush.anand@gmail.com>,
	target-devel@vger.kernel.org, cluster-devel@redhat.com,
	ocfs2-devel@oss.oracle.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Felipe Balbi <balbi@ti.com>
Return-path: <target-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150930164301.GP32625@saruman.tx.rr.com>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 30, 2015 at 11:43:01AM -0500, Felipe Balbi wrote:
> Seems like there are *ton* of uses of container_of() wrapped within a simple
> macro. What convention are you talking about, again ?

The convention of using inline functions over macros when possible.
We don't do that all the time but that's where we wanna be in general.

> And again, what benefit is an inline function bringing in this specific
> case ? As for a technical reason, we know the macro definition will be
> copied Verbatim into the caller body. GCC might decide to not inline
> those helpers (unlikely, but could).

That's really grasping at straws.  Let's not go there.

For simple stuff like container_of(), a more valid reason would be
"it's shorter and sweeter and AFAICS doesn't have any known downsides
of using macros" but this ultimately is a bike-shedding problem.

You asked where and why we said we prefer inline functions so that's
the answer (aside from individual technical advantages).  It's not an
absolute rule but we're better off if we try to keep things consistent
if possible.  As for this specific case, I don't know.  I might do the
macro too just because it's less typing and I don't really care but at
the same time I'd just switch to inline if somebody points it out.

-- 
tejun
