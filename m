From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: xfrm4_state_afinfo size increase (was: Re: xfrm: Add a xfrm type offload.)
Date: Thu, 4 May 2017 10:08:07 +0200
Message-ID: <CAMuHMdW=qBz+0qaXRRdBc=jKBA9aGqKafrQQ8rUiQhKv2UmW_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33944 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750981AbdEDIIJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 04:08:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Steffen,

On Wed, May 3, 2017 at 3:05 AM, Linux Kernel Mailing List
<linux-kernel@vger.kernel.org> wrote:
> Web:        https://git.kernel.org/torvalds/c/9d389d7f84bbb3a294eb05f7dfe2076e291fc150
> Commit:     9d389d7f84bbb3a294eb05f7dfe2076e291fc150
> Parent:     c7ef8f0c020ac43c8a692bf989017c06ab1fdf0f
> Refname:    refs/heads/master
> Author:     Steffen Klassert <steffen.klassert@secunet.com>
> AuthorDate: Fri Apr 14 10:05:44 2017 +0200
> Committer:  Steffen Klassert <steffen.klassert@secunet.com>
> CommitDate: Fri Apr 14 10:05:44 2017 +0200
>
>     xfrm: Add a xfrm type offload.
>
>     We add a struct  xfrm_type_offload so that we have the offloaded
>     codepath separated to the non offloaded codepath. With this the
>     non offloade and the offloaded codepath can coexist.
>
>     Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>  include/net/xfrm.h    | 28 +++++++++++++++-----
>  net/xfrm/xfrm_state.c | 73 +++++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 95 insertions(+), 6 deletions(-)
>
> diff --git a/include/net/xfrm.h b/include/net/xfrm.h
> index 9e3dc7b81a4d..159342f3e72b 100644
> --- a/include/net/xfrm.h
> +++ b/include/net/xfrm.h

> @@ -314,12 +316,14 @@ void km_state_expired(struct xfrm_state *x, int hard, u32 portid);
>  int __xfrm_state_delete(struct xfrm_state *x);
>
>  struct xfrm_state_afinfo {
> -       unsigned int            family;
> -       unsigned int            proto;
> -       __be16                  eth_proto;
> -       struct module           *owner;
> -       const struct xfrm_type  *type_map[IPPROTO_MAX];
> -       struct xfrm_mode        *mode_map[XFRM_MODE_MAX];
> +       unsigned int                    family;
> +       unsigned int                    proto;
> +       __be16                          eth_proto;
> +       struct module                   *owner;
> +       const struct xfrm_type          *type_map[IPPROTO_MAX];
> +       const struct xfrm_type_offload  *type_offload_map[IPPROTO_MAX];
> +       struct xfrm_mode                *mode_map[XFRM_MODE_MAX];

Bloat-o-meter reports the addition of xfrm_state_afinfo.type_offload_map[]
increases the static kernel size by 1 KiB on 32-bit platforms (double on 64-bit
platforms):

function                                     old     new   delta
    xfrm4_state_afinfo                          1102    2126   +1024

While IPPROTO_MAX = 256, the defined list of IP protocols is spread
sparsely over the number space, but I assume all values may occur?

Perhaps type_offload_map[] (and type_map[] while at it) can be allocated at
runtime instead, when the feature is used?

Thanks!

Gr{oetje,eeting}s,

                        Geert
