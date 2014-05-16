From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net/dsa/dsa.c: increment chip_index during of_node
 handling on dsa_of_probe()
Date: Fri, 16 May 2014 09:12:12 -0700
Message-ID: <CAGVrzcYgje8G-e5B9JpCoS1fbLF-pmgWgvzzkiAVmN2YQdt6NA@mail.gmail.com>
References: <1400214104-27699-1-git-send-email-fg@emlix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Fabian Godehardt <fg@emlix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:35875 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754651AbaEPQMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 12:12:53 -0400
Received: by mail-qg0-f46.google.com with SMTP id q108so4519083qgd.33
        for <netdev@vger.kernel.org>; Fri, 16 May 2014 09:12:52 -0700 (PDT)
In-Reply-To: <1400214104-27699-1-git-send-email-fg@emlix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-05-15 21:21 GMT-07:00 Fabian Godehardt <fg@emlix.com>:
> Adding more than one chip on device-tree currently causes the probing
> routine to always use the first chips data pointer.

This looks good to me, your patch subject should be something like
"net: dsa: increment chip_index during of_node handling in
dsa_of_probe()"

>
> Signed-off-by: Fabian Godehardt <fg@emlix.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  net/dsa/dsa.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> index 0eb5d5e..5db37ce 100644
> --- a/net/dsa/dsa.c
> +++ b/net/dsa/dsa.c
> @@ -406,8 +406,9 @@ static int dsa_of_probe(struct platform_device *pdev)
>                 goto out_free;
>         }
>
> -       chip_index = 0;
> +       chip_index = -1;
>         for_each_available_child_of_node(np, child) {
> +               chip_index++;
>                 cd = &pd->chip[chip_index];
>
>                 cd->mii_bus = &mdio_bus->dev;
> --
> 1.8.2.61.g7b9a419
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Florian
