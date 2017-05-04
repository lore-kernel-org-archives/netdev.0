From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: xfrm4_state_afinfo size increase (was: Re: xfrm: Add a xfrm type
 offload.)
Date: Thu, 4 May 2017 11:16:40 +0200
Message-ID: <20170504091640.GR2649@secunet.com>
References: <CAMuHMdW=qBz+0qaXRRdBc=jKBA9aGqKafrQQ8rUiQhKv2UmW_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:34620 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751765AbdEDJQx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 4 May 2017 05:16:53 -0400
Content-Disposition: inline
In-Reply-To: <CAMuHMdW=qBz+0qaXRRdBc=jKBA9aGqKafrQQ8rUiQhKv2UmW_Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 04, 2017 at 10:08:07AM +0200, Geert Uytterhoeven wrote:
> > @@ -314,12 +316,14 @@ void km_state_expired(struct xfrm_state *x, int hard, u32 portid);
> >  int __xfrm_state_delete(struct xfrm_state *x);
> >
> >  struct xfrm_state_afinfo {
> > -       unsigned int            family;
> > -       unsigned int            proto;
> > -       __be16                  eth_proto;
> > -       struct module           *owner;
> > -       const struct xfrm_type  *type_map[IPPROTO_MAX];
> > -       struct xfrm_mode        *mode_map[XFRM_MODE_MAX];
> > +       unsigned int                    family;
> > +       unsigned int                    proto;
> > +       __be16                          eth_proto;
> > +       struct module                   *owner;
> > +       const struct xfrm_type          *type_map[IPPROTO_MAX];
> > +       const struct xfrm_type_offload  *type_offload_map[IPPROTO_MAX];
> > +       struct xfrm_mode                *mode_map[XFRM_MODE_MAX];
> 
> Bloat-o-meter reports the addition of xfrm_state_afinfo.type_offload_map[]
> increases the static kernel size by 1 KiB on 32-bit platforms (double on 64-bit
> platforms):
> 
> function                                     old     new   delta
>     xfrm4_state_afinfo                          1102    2126   +1024
> 
> While IPPROTO_MAX = 256, the defined list of IP protocols is spread
> sparsely over the number space, but I assume all values may occur?

Actually no, I think we could boil this down to less than ten
really used protocols by mapping the IPPROTO numbers to some
XFRMPROTO numbers.

I'll look into this.

Thanks!
