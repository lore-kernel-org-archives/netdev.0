From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] mlx4: do not fire tasklet unless necessary
Date: Wed, 15 Feb 2017 06:04:03 -0800
Message-ID: <1487167443.1311.8.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1486729678.7793.139.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG9HWiNfGaWF_uB6F0BttPbzc_eSpow_zv7FwiK3GWoYQA@mail.gmail.com>
         <1487165355.1311.2.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>, jackm@mellanox.com
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34696 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750719AbdBOOEF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 09:04:05 -0500
Received: by mail-pf0-f194.google.com with SMTP id o64so7882476pfb.1
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 06:04:05 -0800 (PST)
In-Reply-To: <1487165355.1311.2.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-02-15 at 05:29 -0800, Eric Dumazet wrote:

> 
> mlx4_eq_int() is a hard irq handler.
> 
> How a tasklet could run in the middle of it ?
> 
> A tasklet is a softirq handler.

Speaking of mlx4_eq_int() , 50% of cycles are spent on mb() (mfence)
in eq_set_ci()

I wonder why this very expensive mb() is required, right before exiting
the interrupt handler.
 
