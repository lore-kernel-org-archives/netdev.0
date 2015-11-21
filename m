From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 9/9] netfilter: implement xt_cgroup cgroup2 path match
Date: Sat, 21 Nov 2015 12:04:25 -0500
Message-ID: <20151121170425.GD3428@htj.duckdns.org>
References: <1448122441-9335-1-git-send-email-tj@kernel.org>
 <1448122441-9335-10-git-send-email-tj@kernel.org>
 <20151121165605.GC25336@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org,
	daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, nhorman-2XuSBdqkA4SvXiR4WA35Jg@public.gmane.org,
	lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-team-b10kYP2dOMg@public.gmane.org, ninasc-b10kYP2dOMg@public.gmane.org,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Jan Engelhardt <jengelh-9+2X+4sQBs8@public.gmane.org>
To: Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20151121165605.GC25336-E0PNVn5OA6ohrxcnuTQ+TQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,

On Sat, Nov 21, 2015 at 05:56:06PM +0100, Florian Westphal wrote:
> > +struct xt_cgroup_info_v1 {
> > +	__u8		has_path;
> > +	__u8		has_classid;
> > +	__u8		invert_path;
> > +	__u8		invert_classid;
> > +	char		path[PATH_MAX];
> > +	__u32		classid;
> > +
> > +	/* kernel internal data */
> > +	void		*priv __attribute__((aligned(8)));
> > +};
> 
> Ahem.  Am I reading this right? This struct is > 4k in size?
> If so -- Ugh.  Does sizeof(path) really have to be PATH_MAX?

Hmmm... yeap but would this be an acutual problem?  We can try to make
it shorter but idk it ultimately is a path.  Another solution would be
trying to pass inode around but that is problematic with showing and
printing rules as the only way to reverse-map inode to path is walking
the tree and the cgroup may already be gone at that point.  While >4k
struct isn't pretty, this looks like the path of least resistance.

Thanks.

-- 
tejun
