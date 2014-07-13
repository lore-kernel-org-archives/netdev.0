From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] net: filter: sk_chk_filter() no longer mangles filter
Date: Sun, 13 Jul 2014 03:29:26 +0200
Message-ID: <CAADnVQKNyo3mWkeR0m_Lnmk45xBj2foD6LB22_ZmBP_J5dn+hA@mail.gmail.com>
References: <53BF8DEC.4000307@kristov.de>
	<CAADnVQLQR9fYVGfxfnwpirXt4CwBUzr36tJL+aEoo0err7cppw@mail.gmail.com>
	<53C10C8A.70706@redhat.com>
	<1405172956.3515.41.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <dborkman@redhat.com>,
	David Miller <davem@davemloft.net>,
	Christoph Schulz <develop@kristov.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-ppp@vger.kernel.org, paulus@samba.org, isdn@linux-pingi.de
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <1405172956.3515.41.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 12, 2014 at 3:49 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Add const attribute to filter argument to make clear it is no
> longer modified.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

makes sense. thanks!

Acked-by: Alexei Starovoitov <ast@plumgrid.com>

> ---
>  include/linux/filter.h |    2 +-
>  net/core/filter.c      |    6 +++---
>  2 files changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/include/linux/filter.h b/include/linux/filter.h
> index b885dcb7eaca..c43c8258e682 100644
> --- a/include/linux/filter.h
> +++ b/include/linux/filter.h
> @@ -362,7 +362,7 @@ void sk_unattached_filter_destroy(struct sk_filter *fp);
>  int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk);
>  int sk_detach_filter(struct sock *sk);
>
> -int sk_chk_filter(struct sock_filter *filter, unsigned int flen);
> +int sk_chk_filter(const struct sock_filter *filter, unsigned int flen);
>  int sk_get_filter(struct sock *sk, struct sock_filter __user *filter,
>                   unsigned int len);
>
> diff --git a/net/core/filter.c b/net/core/filter.c
> index 87af1e3e56c0..b90ae7fb3b89 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -1085,7 +1085,7 @@ err:
>   * a cell if not previously written, and we check all branches to be sure
>   * a malicious user doesn't try to abuse us.
>   */
> -static int check_load_and_stores(struct sock_filter *filter, int flen)
> +static int check_load_and_stores(const struct sock_filter *filter, int flen)
>  {
>         u16 *masks, memvalid = 0; /* One bit per cell, 16 cells */
>         int pc, ret = 0;
> @@ -1218,7 +1218,7 @@ static bool chk_code_allowed(u16 code_to_probe)
>   *
>   * Returns 0 if the rule set is legal or -EINVAL if not.
>   */
> -int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
> +int sk_chk_filter(const struct sock_filter *filter, unsigned int flen)
>  {
>         bool anc_found;
>         int pc;
> @@ -1228,7 +1228,7 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
>
>         /* Check the filter code now */
>         for (pc = 0; pc < flen; pc++) {
> -               struct sock_filter *ftest = &filter[pc];
> +               const struct sock_filter *ftest = &filter[pc];
>
>                 /* May we actually operate on this code? */
>                 if (!chk_code_allowed(ftest->code))
>
>
