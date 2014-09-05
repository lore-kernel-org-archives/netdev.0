From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH RFC 1/1] net: fec: change data structure to support multiqueue
Date: Fri, 5 Sep 2014 17:32:40 -0300
Message-ID: <CAOMZO5B08M6n0rXfgZkVNb-0awVQdJ56aMokimCunVsjg03AZg@mail.gmail.com>
References: <1409945994-15593-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Duan Fugang-B38611 <b38611@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Frank Li <Frank.Li@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:37352 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750940AbaIEUcm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 16:32:42 -0400
Received: by mail-lb0-f175.google.com with SMTP id u10so14015427lbd.6
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2014 13:32:40 -0700 (PDT)
In-Reply-To: <1409945994-15593-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 5, 2014 at 4:39 PM, Frank Li <Frank.Li@freescale.com> wrote:

> +       txq = kzalloc(sizeof(*txq), GFP_KERNEL);
> +       if (!txq)
> +               return -ENOMEM;
> +       fep->tx_queue[0] = txq;
> +
> +       rxq = kzalloc(sizeof(*rxq), GFP_KERNEL);
> +       if (!rxq) {
> +               kfree(txq);
> +               return -ENOMEM;
> +       }

....

>         /* Allocate memory for buffer descriptors. */
> -       cbd_base = dma_alloc_coherent(NULL, bd_size, &fep->bd_dma,
> +       cbd_base = dma_alloc_coherent(NULL, bd_size, &bd_dma,
>                                       GFP_KERNEL);
>         if (!cbd_base)
>                 return -ENOMEM;

You should kfree txq and rxq before returning here.
