From: "Luis R. Rodriguez" <mcgrof-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [Intel-gfx] [PATCH 4/4] drm/i915: Move ioremap_wc tracking onto
 VMA
Date: Wed, 20 Apr 2016 23:27:27 +0200
Message-ID: <20160420212727.GS1990@wotan.suse.de>
References: <20160419123028.GI1990@wotan.suse.de>
 <1461069238-31539-1-git-send-email-chris@chris-wilson.co.uk>
 <1461069238-31539-4-git-send-email-chris@chris-wilson.co.uk>
 <20160420091054.GL1990@wotan.suse.de>
 <20160420111730.GL2510@phenom.ffwll.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "Luis R. Rodriguez" <mcgrof-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Chris Wilson <chris-Y6uKTt2uX1cEflXRtASbqLVCufUGDwFn@public.gmane.org>,
	David Airlie <airlied-cv59FeDIM0c@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	intel-gfx-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"Peter Zijlstra (Intel)" <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Daniel Vetter <daniel.vetter-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Yishai Hadas <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	David Hildenbrand <dahi-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160420111730.GL2510-dv86pmgwkMBes7Z6vYuT8azUEOm+Xw19@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 20, 2016 at 01:17:30PM +0200, Daniel Vetter wrote:
> On Wed, Apr 20, 2016 at 11:10:54AM +0200, Luis R. Rodriguez wrote:
> > Reason I ask is since I noticed a while ago a lot of drivers
> > were using info->fix.smem_start and info->fix.smem_len consistently
> > for their ioremap'd areas it might make sense instead to let the
> > internal framebuffer (register_framebuffer()) optionally manage the
> > ioremap_wc() for drivers, given that this is pretty generic stuff.
> 
> All that legacy fbdev stuff is just for legacy support, and I prefer to
> have that as dumb as possible. There's been some discussion even around
> lifting the "kick out firmware fb driver" out of fbdev, since we'd need it
> to have a simple drm driver for e.g. uefi.
> 
> But I definitely don't want a legacy horror show like fbdev to
> automagically take care of device mappings for drivers.

Makes sense, it also still begs the question if more modern APIs
could manage the ioremap for you. Evidence shows people get
sloppy and if things were done internally with helpers it may
be easier to later make adjustments.

  Luis
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
