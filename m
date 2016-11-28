From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: [PATCH net-next v2 1/1] driver: ipvlan: Use NF_IP_PRI_LAST as
 hook priority instead of INT_MAX
Date: Mon, 28 Nov 2016 11:26:13 -0800
Message-ID: <CAF2d9jhdJ55ednEnj7PUezRJ+HJ-3PTH0=B3D9DyYtDVp7RBfw@mail.gmail.com>
References: <1480245482-10357-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        linux-netdev <netdev@vger.kernel.org>, gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f179.google.com ([209.85.161.179]:35515 "EHLO
        mail-yw0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752456AbcK1T0f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 14:26:35 -0500
Received: by mail-yw0-f179.google.com with SMTP id i145so123600929ywg.2
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 11:26:34 -0800 (PST)
In-Reply-To: <1480245482-10357-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 27, 2016 at 3:18 AM,  <fgao@ikuai8.com> wrote:
> From: Gao Feng <fgao@ikuai8.com>
>
> It is better to use NF_IP_PRI_LAST instead of INT_MAX as hook priority.
> The former is good at readability and easier to maintain.
>
This IPvlan hook has to be "absolute" last hook and at this moment
NF_IP_PRI_LAST is set as INT_MAX so it's not altering anything.

If for whatever reasons the value of NF_IP_PRI_LAST changes, there
could be random IPvlan failure. Since that possibility cannot be
denied and there are several places INT_MAX is still used as hook
priority, I don't see any gain in having this patch in fact there
could be future (possible) downside.

> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> ---
>  v2: Add the lost header file. It is added in local but not in v1 patch
>  v1: Inital patch
>
>  drivers/net/ipvlan/ipvlan_main.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
> index ab90b22..01c7446 100644
> --- a/drivers/net/ipvlan/ipvlan_main.c
> +++ b/drivers/net/ipvlan/ipvlan_main.c
> @@ -7,6 +7,7 @@
>   *
>   */
>
> +#include "linux/netfilter_ipv4.h"
>  #include "ipvlan.h"
>
>  static u32 ipvl_nf_hook_refcnt = 0;
> @@ -16,13 +17,13 @@
>                 .hook     = ipvlan_nf_input,
>                 .pf       = NFPROTO_IPV4,
>                 .hooknum  = NF_INET_LOCAL_IN,
> -               .priority = INT_MAX,
> +               .priority = NF_IP_PRI_LAST,
>         },
>         {
>                 .hook     = ipvlan_nf_input,
>                 .pf       = NFPROTO_IPV6,
>                 .hooknum  = NF_INET_LOCAL_IN,
> -               .priority = INT_MAX,
> +               .priority = NF_IP_PRI_LAST,
>         },
>  };
>
> --
> 1.9.1
>
>
