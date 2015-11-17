From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH iptables] libxt_cgroup2: add support for cgroup2 path
 matching
Date: Tue, 17 Nov 2015 18:09:24 -0500
Message-ID: <20151117230924.GL22864@mtj.duckdns.org>
References: <1447789240-29394-1-git-send-email-tj@kernel.org>
 <20151117194221.GB22864@mtj.duckdns.org>
 <alpine.LSU.2.20.1511172356570.13966@nerf40.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org, lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-team-b10kYP2dOMg@public.gmane.org,
	daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org,
	nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
To: Jan Engelhardt <jengelh-9+2X+4sQBs8@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.20.1511172356570.13966-Og55a6x16tXH9RFtKMg/Ng@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,

On Wed, Nov 18, 2015 at 12:02:01AM +0100, Jan Engelhardt wrote:
> On Tuesday 2015-11-17 20:42, Tejun Heo wrote:
> >+static void cgroup2_save(const void *ip, const struct xt_entry_match *match)
> >+{
> >+	const struct xt_cgroup2_info *info = (void *)match->data;
> >+
> >+	printf("%s --path %s", info->invert ? " !" : "", info->path);
> >+}
> 
> Can cgroup path names contain anything fancy, like spaces, backslashes, etc.?
> If so, xtables_save_string() will be needed here.

Will update.

> >+static struct xtables_match cgroup2_match = {
> >+	.family		= NFPROTO_UNSPEC,
> >+	.name		= "cgroup2",
> >+	.version	= XTABLES_VERSION,
> >+	.size		= XT_ALIGN(sizeof(struct xt_cgroup2_info)),
> >+	.userspacesize	= XT_ALIGN(sizeof(struct xt_cgroup2_info)),
> 
> userspacesize must not include xt_cgroup2_info.priv.
> Change to offsetof(...), cf. other .c modules which do this.

Ah, okay.

...
> >+\fBIMPORTANT\fP: when being used in the INPUT chain, the cgroup2
> >+matcher is currently only of limited functionality, meaning it
> >+will only match on packets that are processed for local sockets
> >+through early socket demuxing. Therefore, general usage on the
> >+INPUT chain is disadviced unless the implications are well
> 
> is disadviced (sic)  -> is not advised

Will update.  That's copied verbatim from xt_cgroup tho.  Will create
a patch to update that too.

Thanks.

-- 
tejun
