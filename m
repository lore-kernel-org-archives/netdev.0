From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH v3 6/7] tcp buffer limitation: per-cgroup limit
Date: Wed, 21 Sep 2011 23:01:46 -0700
Message-ID: <CAHH2K0Yuji2_2pMdzEaMvRx0KE7OOaoEGT+OK4gJgTcOPKuT9g@mail.gmail.com>
References: <1316393805-3005-1-git-send-email-glommer@parallels.com> <1316393805-3005-7-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com,
        kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com,
        davem@davemloft.net, netdev@vger.kernel.org, linux-mm@kvack.org,
        kirill@shutemov.name
To: Glauber Costa <glommer@parallels.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1316393805-3005-7-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 18, 2011 at 5:56 PM, Glauber Costa <glommer@parallels.com> wrot=
e:
> +static inline bool mem_cgroup_is_root(struct mem_cgroup *mem)
> +{
> + =A0 =A0 =A0 return (mem =3D=3D root_mem_cgroup);
> +}
> +

Why are you adding a copy of mem_cgroup_is_root().  I see one already
in v3.0.  Was it deleted in a previous patch?

> +static int tcp_write_maxmem(struct cgroup *cgrp, struct cftype *cft, u64=
 val)
> +{
> + =A0 =A0 =A0 struct mem_cgroup *sg =3D mem_cgroup_from_cont(cgrp);
> + =A0 =A0 =A0 struct mem_cgroup *parent =3D parent_mem_cgroup(sg);
> + =A0 =A0 =A0 struct net *net =3D current->nsproxy->net_ns;
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 if (!cgroup_lock_live_group(cgrp))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;

Why is cgroup_lock_live_cgroup() needed here?  Does it protect updates
to sg->tcp_prot_mem[*]?

> +static u64 tcp_read_maxmem(struct cgroup *cgrp, struct cftype *cft)
> +{
> + =A0 =A0 =A0 struct mem_cgroup *sg =3D mem_cgroup_from_cont(cgrp);
> + =A0 =A0 =A0 u64 ret;
> +
> + =A0 =A0 =A0 if (!cgroup_lock_live_group(cgrp))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;

Why is cgroup_lock_live_cgroup() needed here?  Does it protect updates
to sg->tcp_max_memory?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
