From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v15 02/13] net/compat.c,linux/filter.h: share
 compat_sock_fprog
Date: Fri, 16 Mar 2012 11:16:39 -0700
Message-ID: <1331921799.19406.20.camel@edumazet-glaptop>
References: <1331781125-15658-1-git-send-email-wad@chromium.org>
	 <1331781125-15658-3-git-send-email-wad@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, indan@nul.nu, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, markus@chromium.org,
	coreyb@linux.vnet.ibm.com, keescook@chromium.org
To: Will Drewry <wad@chromium.org>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1331781125-15658-3-git-send-email-wad@chromium.org>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-03-14 at 22:11 -0500, Will Drewry wrote:
> Any other users of bpf_*_filter that take a struct sock_fprog from
> userspace will need to be able to also accept a compat_sock_fprog
> if the arch supports compat calls.  This change let's the existing
> compat_sock_fprog be shared.
> 
> Acked-by: Serge Hallyn <serge.hallyn@canonical.com>
> Signed-off-by: Will Drewry <wad@chromium.org>
> 
> v14: rebase/nochanges
> v13: rebase on to 88ebdda6159ffc15699f204c33feb3e431bf9bdc
> v12: rebase on to linux-next
> v11: introduction
> ---
>  include/linux/filter.h |   11 +++++++++++
>  net/compat.c           |    8 --------
>  2 files changed, 11 insertions(+), 8 deletions(-)
> 
> diff --git a/include/linux/filter.h b/include/linux/filter.h
> index aaa2e80..f2e5315 100644
> --- a/include/linux/filter.h
> +++ b/include/linux/filter.h
> @@ -10,6 +10,7 @@
>  
>  #ifdef __KERNEL__
>  #include <linux/atomic.h>
> +#include <linux/compat.h>
>  #endif
>  
>  /*
> @@ -132,6 +133,16 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
>  
>  #ifdef __KERNEL__
>  
> +#ifdef CONFIG_COMPAT
> +/*
> + * A struct sock_filter is architecture independent.
> + */
> +struct compat_sock_fprog {
> +	u16		len;
> +	compat_uptr_t	filter;		/* struct sock_filter * */
> +};
> +#endif
> +
>  struct sk_buff;
>  struct sock;
>  
> diff --git a/net/compat.c b/net/compat.c
> index 6def90e..c5c61c8 100644
> --- a/net/compat.c
> +++ b/net/compat.c
> @@ -326,14 +326,6 @@ void scm_detach_fds_compat(struct msghdr *kmsg, struct scm_cookie *scm)
>  	__scm_destroy(scm);
>  }
>  
> -/*
> - * A struct sock_filter is architecture independent.
> - */
> -struct compat_sock_fprog {
> -	u16		len;
> -	compat_uptr_t	filter;		/* struct sock_filter * */
> -};
> -
>  static int do_set_attach_filter(struct socket *sock, int level, int optname,
>  				char __user *optval, unsigned int optlen)
>  {

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
