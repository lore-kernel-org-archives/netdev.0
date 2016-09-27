From: Liping Zhang <zlpnobody@gmail.com>
Subject: Re: [PATCH nf-next] netfilter: xt_osf: Use explicit member assignment
 to avoid implicit no padding rule
Date: Tue, 27 Sep 2016 13:49:58 +0800
Message-ID: <CAML_gOcQt3MuDw3JAXYab1bKFaRuKgVO4jBaM22NOCShVoKmeA@mail.gmail.com>
References: <1474951193-3486-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Patrick McHardy <kaber@trash.net>,
        netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        Feng Gao <gfree.wind@gmail.com>
To: fgao@ikuai8.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1474951193-3486-1-git-send-email-fgao@ikuai8.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Feng,

2016-09-27 12:39 GMT+08:00  <fgao@ikuai8.com>:
> From: Gao Feng <fgao@ikuai8.com>
>
> Current xt_osf codes use memcmp to check if two user fingers are same,
> so it depends on that the struct xt_osf_user_finger is no padding.
> It is one implicit rule, and is not good to maintain.
>
> Now use zero memory and assign the members explicitly.
>
> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> ---
>  net/netfilter/xt_osf.c | 32 ++++++++++++++++++++++++++++++--
>  1 file changed, 30 insertions(+), 2 deletions(-)
>
> diff --git a/net/netfilter/xt_osf.c b/net/netfilter/xt_osf.c
> index 2455b69..9793670 100644
> --- a/net/netfilter/xt_osf.c
> +++ b/net/netfilter/xt_osf.c
> @@ -61,6 +61,34 @@ static const struct nla_policy xt_osf_policy[OSF_ATTR_MAX + 1] = {
>         [OSF_ATTR_FINGER]       = { .len = sizeof(struct xt_osf_user_finger) },
>  };
>
> +static void copy_user_finger(struct xt_osf_user_finger *dst,
> +                            const struct xt_osf_user_finger *src)
> +{
> +#define OSF_COPY_MEMBER(mem)   dst->mem = src->mem
> +
> +       int i;
> +
> +       OSF_COPY_MEMBER(wss.wc);
> +       OSF_COPY_MEMBER(wss.val);
> +
> +       OSF_COPY_MEMBER(ttl);
> +       OSF_COPY_MEMBER(df);
> +       OSF_COPY_MEMBER(ss);
> +       OSF_COPY_MEMBER(mss);
> +       OSF_COPY_MEMBER(opt_num);
> +
> +       memcpy(dst->genre, src->genre, sizeof(dst->genre));
> +       memcpy(dst->version, src->version, sizeof(dst->version));
> +       memcpy(dst->subtype, src->subtype, sizeof(dst->subtype));
> +
> +       for (i = 0; i < MAX_IPOPTLEN; ++i) {
> +               OSF_COPY_MEMBER(opt[i].kind);
> +               OSF_COPY_MEMBER(opt[i].length);
> +               OSF_COPY_MEMBER(opt[i].wc.wc);
> +               OSF_COPY_MEMBER(opt[i].wc.val);
> +       }
> +}
> +

This xt_osf_user_finger{} is carefully designed, no padding now, and
will not be changed in the future, otherwise backward compatibility will
be broken.

I don't think this convert is necessary, actually it is a little ugly, and will
increase the maintenance burden.
