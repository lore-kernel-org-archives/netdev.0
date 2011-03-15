From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 03/17] cgroup,
	rcu: convert call_rcu(__free_css_id_cb) to kfree_rcu()
Date: Tue, 15 Mar 2011 13:04:33 -0700
Message-ID: <AANLkTi=coPDZRv7ydnP4q-Qztq=FLaa+neNjTvcFowAE@mail.gmail.com>
References: <4D7F3610.6000809@cn.fujitsu.com> <4D7F37BA.5000308@cn.fujitsu.com>
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
In-Reply-To: <4D7F37BA.5000308-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
>
> The rcu callback __free_css_id_cb() just calls a kfree(),
> so we use kfree_rcu() instead of the call_rcu(__free_css_id_cb).
>
> Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>


> ---
> =A0kernel/cgroup.c | =A0 10 +---------
> =A01 files changed, 1 insertions(+), 9 deletions(-)
>
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 5c83c91..b7d3f6d 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -4612,14 +4612,6 @@ bool css_is_ancestor(struct cgroup_subsys_state *c=
hild,
> =A0 =A0 =A0 =A0return ret;
> =A0}
>
> -static void __free_css_id_cb(struct rcu_head *head)
> -{
> - =A0 =A0 =A0 struct css_id *id;
> -
> - =A0 =A0 =A0 id =3D container_of(head, struct css_id, rcu_head);
> - =A0 =A0 =A0 kfree(id);
> -}
> -
> =A0void free_css_id(struct cgroup_subsys *ss, struct cgroup_subsys_state =
*css)
> =A0{
> =A0 =A0 =A0 =A0struct css_id *id =3D css->id;
> @@ -4634,7 +4626,7 @@ void free_css_id(struct cgroup_subsys *ss, struct c=
group_subsys_state *css)
> =A0 =A0 =A0 =A0spin_lock(&ss->id_lock);
> =A0 =A0 =A0 =A0idr_remove(&ss->idr, id->id);
> =A0 =A0 =A0 =A0spin_unlock(&ss->id_lock);
> - =A0 =A0 =A0 call_rcu(&id->rcu_head, __free_css_id_cb);
> + =A0 =A0 =A0 kfree_rcu(id, rcu_head);
> =A0}
> =A0EXPORT_SYMBOL_GPL(free_css_id);
>
> --
> 1.7.4
>
