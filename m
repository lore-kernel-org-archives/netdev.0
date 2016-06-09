From: Paul Moore <pmoore@redhat.com>
Subject: Re: [PATCH] iucv: properly clone LSM attributes to newly created
 child sockets
Date: Thu, 9 Jun 2016 09:01:52 -0400
Message-ID: <CAGH-Kgs-jg381WW818NKhdCkd06yXSRrgN0+A4migVM6FwUSVg@mail.gmail.com>
References: <146547719343.9258.4899338680484754606.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov
To: linux-s390@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <146547719343.9258.4899338680484754606.stgit@localhost>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 9, 2016 at 8:59 AM, Paul Moore <pmoore@redhat.com> wrote:
> From: Paul Moore <paul@paul-moore.com>
>
> Much like we had to do for AF_BLUETOOTH and AF_ALG, make sure we
> properly clone the parent socket's LSM attributes to newly created
> child sockets.
>
> Signed-off-by: Paul Moore <paul@paul-moore.com>
> ---
>  net/iucv/af_iucv.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)

Another small, and obvious, fix so I'm going to merge it into
selinux#next now, but if anyone has an objection please let me know.

> diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
> index fc3598a..a0d1e36 100644
> --- a/net/iucv/af_iucv.c
> +++ b/net/iucv/af_iucv.c
> @@ -22,6 +22,7 @@
>  #include <linux/skbuff.h>
>  #include <linux/init.h>
>  #include <linux/poll.h>
> +#include <linux/security.h>
>  #include <net/sock.h>
>  #include <asm/ebcdic.h>
>  #include <asm/cpcmd.h>
> @@ -530,8 +531,10 @@ static void iucv_sock_close(struct sock *sk)
>
>  static void iucv_sock_init(struct sock *sk, struct sock *parent)
>  {
> -       if (parent)
> +       if (parent) {
>                 sk->sk_type = parent->sk_type;
> +               security_sk_clone(parent, sk);
> +       }
>  }
>
>  static struct sock *iucv_sock_alloc(struct socket *sock, int proto, gfp_t prio, int kern)
>

-- 
paul moore
security @ redhat
