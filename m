From: Jan Engelhardt <jengelh-9+2X+4sQBs8@public.gmane.org>
Subject: RE: [PATCH 9/9] netfilter: implement xt_cgroup cgroup2 path match
Date: Mon, 23 Nov 2015 18:55:55 +0100 (CET)
Message-ID: <alpine.LSU.2.20.1511231853260.25633@nerf40.vanv.qr>
References: <1448122441-9335-1-git-send-email-tj@kernel.org> <1448122441-9335-10-git-send-email-tj@kernel.org> <20151121165605.GC25336@breakpoint.cc> <063D6719AE5E284EB5DD2968C1650D6D1CBDA8E2@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: 'Florian Westphal' <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org" <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>,
	"kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org" <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	"kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org" <kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org>,
	"daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org" <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	"daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org" <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	"nhorman-2XuSBdqkA4SvXiR4WA35Jg@public.gmane.org" <nhorman-2XuSBdqkA4SvXiR4WA35Jg@public.gmane.org>,
	"lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org" <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	"hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org" <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org" <coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>,
	"cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"kernel-team-b10kYP2dOMg@public.gmane.org" <kernel-team-b10kYP2dOMg@public.gmane.org>,
	"ninasc-b10kYP2dOMg@public.gmane.org" <ninasc-b10kYP2dOMg@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4SvXiR4WA35Jg@public.gmane.org
To: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CBDA8E2-VkEWCZq2GCInGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On Monday 2015-11-23 18:35, David Laight wrote:
>From: Florian Westphal
>> Sent: 21 November 2015 16:56
>> > +struct xt_cgroup_info_v1 {
>> > +	char		path[PATH_MAX];
>> > +	__u32		classid;
>> > +
>> > +	/* kernel internal data */
>> > +	void		*priv __attribute__((aligned(8)));
>> > +};
>> 
>> Ahem.  Am I reading this right? This struct is > 4k in size?
>> If so -- Ugh.  Does sizeof(path) really have to be PATH_MAX?
>
>I've not looked at the use, but could you put 'char path[];'
>as the last member an require any allocations to be long enough
>to contain the actual path?

Oh, smart :)  Yeah, ebt_among does something like that.
(.matchsize = -1, hint)

Except that the "priv" pointer seems to be ruining the fun here -
kernel vars have to be last, which collides with the requirements
for []-type members.
