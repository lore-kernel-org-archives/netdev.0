From: Rami Rosen <roszenrami@gmail.com>
Subject: Re: [PATCH net] xfrm: Fix memory leak of aead algorithm name
Date: Sun, 18 Sep 2016 20:39:41 +0300
Message-ID: <CAKoUArkQE2keAsEwm87S7_BVtoog1DEZjhUs0U8o672mnMRf5Q@mail.gmail.com>
References: <AM4PR0501MB19404B000E4D3A2CF3CB80DEDBF50@AM4PR0501MB1940.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ilan Tayari <ilant@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:36096 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751581AbcIRRjo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 13:39:44 -0400
Received: by mail-lf0-f68.google.com with SMTP id s29so7278111lfg.3
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 10:39:43 -0700 (PDT)
In-Reply-To: <AM4PR0501MB19404B000E4D3A2CF3CB80DEDBF50@AM4PR0501MB1940.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: Rami Rosen <roszenrami@gmail.com>

On 18 September 2016 at 10:42, Ilan Tayari <ilant@mellanox.com> wrote:
> commit 1a6509d99122 ("[IPSEC]: Add support for combined mode algorithms")
> introduced aead. The function attach_aead kmemdup()s the algorithm
> name during xfrm_state_construct().
> However this memory is never freed.
> Implementation has since been slightly modified in
> commit ee5c23176fcc ("xfrm: Clone states properly on migration")
> without resolving this leak.
> This patch adds a kfree() call for the aead algorithm name.
>
> Fixes: 1a6509d99122 ("[IPSEC]: Add support for combined mode algorithms")
> Signed-off-by: Ilan Tayari <ilant@mellanox.com>
> ---
>  net/xfrm/xfrm_state.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
> index 9895a8c..a30f898d 100644
> --- a/net/xfrm/xfrm_state.c
> +++ b/net/xfrm/xfrm_state.c
> @@ -332,6 +332,7 @@ static void xfrm_state_gc_destroy(struct xfrm_state *x)
>  {
>         tasklet_hrtimer_cancel(&x->mtimer);
>         del_timer_sync(&x->rtimer);
> +       kfree(x->aead);
>         kfree(x->aalg);
>         kfree(x->ealg);
>         kfree(x->calg);
> --
> 1.8.3.1
>
