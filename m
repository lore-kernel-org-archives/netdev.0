From: Bruce Fields <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH] Next branch: authgss: authgss.c: Fix warnings for
 uninitizlized variable expire
Date: Tue, 2 Sep 2014 09:21:40 -0400
Message-ID: <20140902132140.GA31793@fieldses.org>
References: <1409571154-50408-1-git-send-email-shakilk1729@gmail.com>
 <CAHQdGtQAwp_QuQE-xmjJNkcxbu7g4QtYQv8qrPT_qWpkym1GZg@mail.gmail.com>
 <5405A15F.2060002@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	Shakil A Khan <shakilk1729-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Linux NFS Mailing List <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel mailing list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Paul McKenney <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	William Andros Adamson <andros-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	Jeffrey Layton <jlayton-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Boaz Harrosh <openosd-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5405A15F.2060002-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 02, 2014 at 01:52:15PM +0300, Boaz Harrosh wrote:
> On 09/01/2014 04:50 PM, Trond Myklebust wrote:
> > On Mon, Sep 1, 2014 at 7:32 AM, Shakil A Khan <shakilk1729-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> >> Signed-off-by : Shakil A Khan <shakilk1729-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> >> ---
> >>  net/sunrpc/auth_gss/auth_gss.c |    2 +-
> >>  1 files changed, 1 insertions(+), 1 deletions(-)
> >>
> >> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> >> index afb292c..bea0951 100644
> >> --- a/net/sunrpc/auth_gss/auth_gss.c
> >> +++ b/net/sunrpc/auth_gss/auth_gss.c
> >> @@ -1387,7 +1387,7 @@ gss_key_timeout(struct rpc_cred *rc)
> >>         struct gss_cred *gss_cred = container_of(rc, struct gss_cred, gc_base);
> >>         struct gss_cl_ctx *ctx;
> >>         unsigned long now = jiffies;
> >> -       unsigned long expire;
> >> +       unsigned long expire = 0;
> >>
> >>         rcu_read_lock();
> >>         ctx = rcu_dereference(gss_cred->gc_ctx);
> >> --
> >> 1.7.1
> > 
> > That would be a compiler bug, not a kernel bug. The kernel code is
> > perfectly correct as it stands, and will never access the
> > uninitialised variable.
> > 
> 
> Than you will need the infamous uninitialised_var()

You'd rather avoid sprinkling that all over, though.  If nothing else it
increases the chances you'll suppress a legimate warning some day.

And unless I'm missing something this one really does look like an
unambiguous compiler bug.

--b.

> 
> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> index afb292c..bea0951 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -1387,7 +1387,7 @@ gss_key_timeout(struct rpc_cred *rc)
>  	struct gss_cred *gss_cred = container_of(rc, struct gss_cred, gc_base);
>  	struct gss_cl_ctx *ctx;
>  	unsigned long now = jiffies;
> -	unsigned long expire;
> +	unsigned long uninitialised_var(expire);
>  
>  	rcu_read_lock();
>  	ctx = rcu_dereference(gss_cred->gc_ctx);
> 
> Cheers
> Boaz
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
