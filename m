From: Dirk Kraft <dirk.kraft@gmail.com>
Subject: Re: Bug - regression - Via velocity interface coming up freezes kernel
Date: Mon, 23 Sep 2013 08:29:31 +0200
Message-ID: <CAFES+iKYWTn-DZRCnWer56rWeGh0t86GAx66OgZ7Jnvm-9fo9w@mail.gmail.com>
References: <CAFES+i+OYq_dDtEqAqkW7qYDrtdzkqc9hBGBDODQuqgvFJE7zg@mail.gmail.com>
	<20130922221109.GA14246@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Julia Lawall <Julia.Lawall@lip6.fr>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:52561 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752335Ab3IWG3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 02:29:32 -0400
Received: by mail-we0-f169.google.com with SMTP id t60so2704111wes.14
        for <netdev@vger.kernel.org>; Sun, 22 Sep 2013 23:29:31 -0700 (PDT)
In-Reply-To: <20130922221109.GA14246@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

On Mon, Sep 23, 2013 at 12:11 AM, Francois Romieu <romieu@fr.zoreil.com> wrote:
[...]
> You can try this one as a wild guess before I have more time to analyze.

By applying the below patch to 3.11-rc1 the problem is gone.

I was only able to do a short test. Could not say if this has any side effects.

Thanks,
Dirk

>
> diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
> index d022bf9..64c42be 100644
> --- a/drivers/net/ethernet/via/via-velocity.c
> +++ b/drivers/net/ethernet/via/via-velocity.c
> @@ -2172,16 +2172,13 @@ static int velocity_poll(struct napi_struct *napi, int budget)
>         unsigned int rx_done;
>         unsigned long flags;
>
> -       spin_lock_irqsave(&vptr->lock, flags);
>         /*
>          * Do rx and tx twice for performance (taken from the VIA
>          * out-of-tree driver).
>          */
> -       rx_done = velocity_rx_srv(vptr, budget / 2);
> -       velocity_tx_srv(vptr);
> -       rx_done += velocity_rx_srv(vptr, budget - rx_done);
> +       rx_done = velocity_rx_srv(vptr, budget);
> +       spin_lock_irqsave(&vptr->lock, flags);
>         velocity_tx_srv(vptr);
> -
>         /* If budget not fully consumed, exit the polling mode */
>         if (rx_done < budget) {
>                 napi_complete(napi);
