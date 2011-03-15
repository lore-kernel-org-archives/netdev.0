From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 02/17] cgroup,
	rcu: convert call_rcu(free_cgroup_rcu) to kfree_rcu()
Date: Tue, 15 Mar 2011 13:04:00 -0700
Message-ID: <AANLkTim-BeRO7DJA4bqKrxED4FbWeV3R-U6cciEkyUQo@mail.gmail.com>
References: <4D7F3610.6000809@cn.fujitsu.com> <4D7F3784.6090307@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        linux-decnet-user-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
        Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
        linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>,
        "Pekka Savola \(ipv6\)" <pekkas-UjJjq++bwZ7HOG6cAo2yLw@public.gmane.org>,
        Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        =?ISO-8859-1?Q?Uwe_Kleine=2DK=F6nig?= <u.kleine-koenig-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
        Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>,
        "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
        Sridhar Samudrala <sri-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
        Vlad Yasevich <vladislav.yasevich-VXdhtT5mjnY@public.gmane.org>,
        Hagen Paul Pfeifer <hagen-GvnIQ6b/HdU@public.gmane.org>,
        "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
        Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>,
        linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Hideaki YOSHIFUJI <yoshfu
To: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4D7F3784.6090307-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

2011/3/15 Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>:
>
> The rcu callback free_cgroup_rcu() just calls a kfree(),
> so we use kfree_rcu() instead of the call_rcu(free_cgroup_rcu).
>
> Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

> ---
> =A0kernel/cgroup.c | =A0 =A09 +--------
> =A01 files changed, 1 insertions(+), 8 deletions(-)
>
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index ad485d4..5c83c91 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -806,13 +806,6 @@ static int cgroup_call_pre_destroy(struct cgroup *cg=
rp)
> =A0 =A0 =A0 =A0return ret;
> =A0}
>
> -static void free_cgroup_rcu(struct rcu_head *obj)
> -{
> - =A0 =A0 =A0 struct cgroup *cgrp =3D container_of(obj, struct cgroup, rc=
u_head);
> -
> - =A0 =A0 =A0 kfree(cgrp);
> -}
> -
> =A0static void cgroup_diput(struct dentry *dentry, struct inode *inode)
> =A0{
> =A0 =A0 =A0 =A0/* is dentry a directory ? if so, kfree() associated cgrou=
p */
> @@ -850,7 +843,7 @@ static void cgroup_diput(struct dentry *dentry, struc=
t inode *inode)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG_ON(!list_empty(&cgrp->pidlists));
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 call_rcu(&cgrp->rcu_head, free_cgroup_rcu);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree_rcu(cgrp, rcu_head);
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0iput(inode);
> =A0}
> --
> 1.7.4
>
