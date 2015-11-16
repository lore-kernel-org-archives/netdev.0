From: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH 05/14] net: tcp_memcontrol: protect all tcp_memcontrol
 calls by jump-label
Date: Mon, 16 Nov 2015 12:52:04 -0500
Message-ID: <20151116175204.GA32544@cmpxchg.org>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-6-git-send-email-hannes@cmpxchg.org>
 <20151114163309.GL31308@esperanza>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-team-b10kYP2dOMg@public.gmane.org
To: Vladimir Davydov <vdavydov-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20151114163309.GL31308@esperanza>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 14, 2015 at 07:33:10PM +0300, Vladimir Davydov wrote:
> On Thu, Nov 12, 2015 at 06:41:24PM -0500, Johannes Weiner wrote:
> > Move the jump-label from sock_update_memcg() and sock_release_memcg()
> > to the callsite, and so eliminate those function calls when socket
> > accounting is not enabled.
> 
> I don't believe this patch's necessary, because these functions aren't
> hot paths. Neither do I think it makes the code look better. Anyway,
> it's rather a matter of personal preference, and the patch looks correct
> to me, so

Yeah, it's not a hotpath. What I like primarily about this patch I
guess is that makes it more consistent how memcg entry is gated. You
don't have to remember which functions have the checks in the caller
and which have it in the function themselves. And I really hate the

static inline void foo(void)
{
	if (foo_enabled())
		__foo()
}

in the headerfile pattern.

> Reviewed-by: Vladimir Davydov <vdavydov-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>

Thanks, I appreciate you acking it despite your personal preference!
