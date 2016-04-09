From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: bcmgenet: use napi_complete_done()
Date: Fri, 08 Apr 2016 22:19:25 -0700
Message-ID: <5B66FA2B-6AAE-4FEB-B5FB-C5C9DF48FDB5@gmail.com>
References: <1460178400.6473.469.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>,
	Petri Gynther <pgynther@google.com>, opendmb@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33731 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750777AbcDIFTl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 01:19:41 -0400
Received: by mail-pf0-f178.google.com with SMTP id 184so88272687pff.0
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 22:19:41 -0700 (PDT)
In-Reply-To: <1460178400.6473.469.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On April 8, 2016 10:06:40 PM PDT, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>From: Eric Dumazet <edumazet@google.com>
>
>By using napi_complete_done(), we allow fine tuning
>of /sys/class/net/ethX/gro_flush_timeout for higher GRO aggregation
>efficiency for a Gbit NIC.
>
>Check commit 24d2e4a50737 ("tg3: use napi_complete_done()") for
>details.
>
>Signed-off-by: Eric Dumazet <edumazet@google.com>
>Cc: Petri Gynther <pgynther@google.com>
>Cc: Florian Fainelli <f.fainelli@gmail.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

Along the same line of changes, we could use napi_schedule_irqoff since NAPI is always scheduled from ISR context.


>---
> drivers/net/ethernet/broadcom/genet/bcmgenet.c |    2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
>diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
>b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
>index f7b42b9fc979..e823013d3125 100644
>--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
>+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
>@@ -1735,7 +1735,7 @@ static int bcmgenet_rx_poll(struct napi_struct
>*napi, int budget)
> 	work_done = bcmgenet_desc_rx(ring, budget);
> 
> 	if (work_done < budget) {
>-		napi_complete(napi);
>+		napi_complete_done(napi, work_done);
> 		ring->int_enable(ring);
> 	}
> 


-- 
Florian
