From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: [PATCH net-next v2 1/1] driver: ipvlan: Use NF_IP_PRI_LAST as
 hook priority instead of INT_MAX
Date: Tue, 29 Nov 2016 09:36:43 -0800
Message-ID: <CAF2d9jga+4uUM1TJeJLz5+t6Dqg2-JNPT-63cp8d74yoto3qAA@mail.gmail.com>
References: <1480245482-10357-1-git-send-email-fgao@ikuai8.com>
 <CAF2d9jhdJ55ednEnj7PUezRJ+HJ-3PTH0=B3D9DyYtDVp7RBfw@mail.gmail.com> <CA+6hz4qXYzC-mEfTqa5HOf9GtL1S1Q=rcz_CtFW5mbvUtj7niA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        linux-netdev <netdev@vger.kernel.org>
To: Gao Feng <fgao@ikuai8.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f177.google.com ([209.85.213.177]:36515 "EHLO
        mail-yb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754194AbcK2RhF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 12:37:05 -0500
Received: by mail-yb0-f177.google.com with SMTP id v78so9821095ybe.3
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 09:37:04 -0800 (PST)
In-Reply-To: <CA+6hz4qXYzC-mEfTqa5HOf9GtL1S1Q=rcz_CtFW5mbvUtj7niA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2016 at 5:14 PM, Gao Feng <fgao@ikuai8.com> wrote:
>
> Hi Mahesh,
>
> On Tue, Nov 29, 2016 at 3:26 AM, Mahesh Bandewar (=E0=A4=AE=E0=A4=B9=E0=
=A5=87=E0=A4=B6 =E0=A4=AC=E0=A4=82=E0=A4=A1=E0=A5=87=E0=A4=B5=E0=A4=BE=E0=
=A4=B0)
> <maheshb@google.com> wrote:
> > On Sun, Nov 27, 2016 at 3:18 AM,  <fgao@ikuai8.com> wrote:
> >> From: Gao Feng <fgao@ikuai8.com>
> >>
> >> It is better to use NF_IP_PRI_LAST instead of INT_MAX as hook priority=
.
> >> The former is good at readability and easier to maintain.
> >>
> > This IPvlan hook has to be "absolute" last hook and at this moment
> > NF_IP_PRI_LAST is set as INT_MAX so it's not altering anything.
>
> Yes. It is same now.
> So I prefer to use NF_IP_PRI_LAST than INT_MAX.
> Because the nf_hook_ops belongs to the netfilter module. i think the
> ipvlan codes should follow its rule.
> Since netfilter has defined some specific priority enum value, why
> don't we follow it?
>
Making changes only to IPvlan is problem-prone as I have explained earlier.

> >
> > If for whatever reasons the value of NF_IP_PRI_LAST changes, there
> > could be random IPvlan failure. Since that possibility cannot be
> > denied and there are several places INT_MAX is still used as hook
> > priority, I don't see any gain in having this patch in fact there
> > could be future (possible) downside.
>
> If the netfilter module changed the value of NF_IP_PRI_LAST, it may
> decrease it and add one check for the hook priority.
> As a result, the ipvlan may fail to register because of invalid priority.
>
> When use INT_MAX not NF_IP_PRI_LAST, there is one assumption that the
> hook priority is never changed.
> I think it is not good as two different modules.
>
> Regards
> Feng
>
> >
> >> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> >> ---
> >>  v2: Add the lost header file. It is added in local but not in v1 patc=
h
> >>  v1: Inital patch
> >>
> >>  drivers/net/ipvlan/ipvlan_main.c | 5 +++--
> >>  1 file changed, 3 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipv=
lan_main.c
> >> index ab90b22..01c7446 100644
> >> --- a/drivers/net/ipvlan/ipvlan_main.c
> >> +++ b/drivers/net/ipvlan/ipvlan_main.c
> >> @@ -7,6 +7,7 @@
> >>   *
> >>   */
> >>
> >> +#include "linux/netfilter_ipv4.h"
> >>  #include "ipvlan.h"
> >>
> >>  static u32 ipvl_nf_hook_refcnt =3D 0;
> >> @@ -16,13 +17,13 @@
> >>                 .hook     =3D ipvlan_nf_input,
> >>                 .pf       =3D NFPROTO_IPV4,
> >>                 .hooknum  =3D NF_INET_LOCAL_IN,
> >> -               .priority =3D INT_MAX,
> >> +               .priority =3D NF_IP_PRI_LAST,
> >>         },
> >>         {
> >>                 .hook     =3D ipvlan_nf_input,
> >>                 .pf       =3D NFPROTO_IPV6,
> >>                 .hooknum  =3D NF_INET_LOCAL_IN,
> >> -               .priority =3D INT_MAX,
> >> +               .priority =3D NF_IP_PRI_LAST,
> >>         },
> >>  };
> >>
> >> --
> >> 1.9.1
> >>
> >>
>
>
