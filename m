From: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
Subject: Re: [PATCH] Next branch: authgss: authgss.c: Fix warnings for
 uninitizlized variable expire
Date: Mon, 1 Sep 2014 09:50:57 -0400
Message-ID: <CAHQdGtQAwp_QuQE-xmjJNkcxbu7g4QtYQv8qrPT_qWpkym1GZg@mail.gmail.com>
References: <1409571154-50408-1-git-send-email-shakilk1729@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux NFS Mailing List <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel mailing list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Paul McKenney <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	William Andros Adamson <andros-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	Jeffrey Layton <jlayton-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Bruce Fields <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
To: Shakil A Khan <shakilk1729-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1409571154-50408-1-git-send-email-shakilk1729-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 1, 2014 at 7:32 AM, Shakil A Khan <shakilk1729-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> Signed-off-by : Shakil A Khan <shakilk1729-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  net/sunrpc/auth_gss/auth_gss.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> index afb292c..bea0951 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -1387,7 +1387,7 @@ gss_key_timeout(struct rpc_cred *rc)
>         struct gss_cred *gss_cred = container_of(rc, struct gss_cred, gc_base);
>         struct gss_cl_ctx *ctx;
>         unsigned long now = jiffies;
> -       unsigned long expire;
> +       unsigned long expire = 0;
>
>         rcu_read_lock();
>         ctx = rcu_dereference(gss_cred->gc_ctx);
> --
> 1.7.1

That would be a compiler bug, not a kernel bug. The kernel code is
perfectly correct as it stands, and will never access the
uninitialised variable.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
