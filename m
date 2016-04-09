From: Petri Gynther <pgynther@google.com>
Subject: Re: [PATCH net-next] net: bcmgenet: use napi_complete_done()
Date: Sat, 9 Apr 2016 10:23:20 -0700
Message-ID: <CAGXr9JEufir3T3JRCPgJnDL3j3a5Ex9mX2OQo5LTFkoR_TBnOw@mail.gmail.com>
References: <1460178400.6473.469.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f41.google.com ([209.85.213.41]:34008 "EHLO
	mail-vk0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753884AbcDIRXV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 13:23:21 -0400
Received: by mail-vk0-f41.google.com with SMTP id e185so170643271vkb.1
        for <netdev@vger.kernel.org>; Sat, 09 Apr 2016 10:23:21 -0700 (PDT)
In-Reply-To: <1460178400.6473.469.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 8, 2016 at 10:06 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> By using napi_complete_done(), we allow fine tuning
> of /sys/class/net/ethX/gro_flush_timeout for higher GRO aggregation
> efficiency for a Gbit NIC.
>
> Check commit 24d2e4a50737 ("tg3: use napi_complete_done()") for details.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Petri Gynther <pgynther@google.com>
> Cc: Florian Fainelli <f.fainelli@gmail.com>

Acked-by: Petri Gynther <pgynther@google.com>

> ---
>  drivers/net/ethernet/broadcom/genet/bcmgenet.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> index f7b42b9fc979..e823013d3125 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> @@ -1735,7 +1735,7 @@ static int bcmgenet_rx_poll(struct napi_struct *napi, int budget)
>         work_done = bcmgenet_desc_rx(ring, budget);
>
>         if (work_done < budget) {
> -               napi_complete(napi);
> +               napi_complete_done(napi, work_done);
>                 ring->int_enable(ring);
>         }
>
>
>
