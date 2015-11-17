From: Jan Engelhardt <jengelh-9+2X+4sQBs8@public.gmane.org>
Subject: Re: [PATCH 5/5] netfilter: implement xt_cgroup2 match
Date: Tue, 17 Nov 2015 23:56:00 +0100 (CET)
Message-ID: <alpine.LSU.2.20.1511172351200.13966@nerf40.vanv.qr>
References: <1447789240-29394-1-git-send-email-tj@kernel.org> <1447789240-29394-6-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org, lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-team-b10kYP2dOMg@public.gmane.org,
	daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org,
	nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1447789240-29394-6-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On Tuesday 2015-11-17 20:40, Tejun Heo wrote:
>@@ -0,0 +1,14 @@
>+#ifndef _XT_CGROUP2_H
>+#define _XT_CGROUP2_H
>+
>+#include <linux/types.h>
>+
>+struct xt_cgroup2_info {
>+	char				path[PATH_MAX];
>+	__u8				invert;

Should <linux/limits.h> be included? (For PATH_MAX)

>+	/* kernel internal data */
>+	void				*priv;
>+};

void *priv __attribute__((aligned(8)));

>+static bool cgroup2_mt(const struct sk_buff *skb, struct xt_action_pa=
ram *par)
>+{
>+	const struct xt_cgroup2_info *info =3D par->matchinfo;
>+	struct cgroup *ancestor =3D info->priv;

There is no modification planned on the cgroup, so this too can be cons=
t struct
cgroup=C2=A0* if-and-when cgroup_is_descendant is made to take const pt=
rs as well.

>+	if (!skb->sk || !sk_fullsock(skb->sk))
>+		return false;
>+
>+	return cgroup_is_descendant(skb->sk->sk_cgroup, ancestor) ^ info->in=
vert;
>+}
