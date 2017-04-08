From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH] net: mvpp2: sleeping function called from invalid
 context
Date: Sat, 8 Apr 2017 15:18:55 +0200
Message-ID: <20170408151855.0a7c89b9@free-electrons.com>
References: <CAPqeXdfNxOd1r7b8xNmrE-nd3r76yuTauGFZmf-W7BxarHF4wg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Mirko Lindner <mlindner@marvell.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        David Miller <davem@davemloft.net>,
        Marcin Wojtas <mw@semihalf.com>,
        Ken Wilson <ken.wilson@opengear.com>
To: Gerald Guillaume <gerald.guillaume@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:60606 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751812AbdDHNS6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 09:18:58 -0400
In-Reply-To: <CAPqeXdfNxOd1r7b8xNmrE-nd3r76yuTauGFZmf-W7BxarHF4wg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Thanks for your patch! However, it is badly line wrapped, you should
consider sending your patch with "git send-email".

On Sat, 8 Apr 2017 15:07:14 +0200, Gerald Guillaume wrote:

> --- linux-3.18/drivers/net/ethernet/marvell/mvpp2.c     2017-04-03
> 10:29:31.863264347 +0200
> +++ linux-3.x/drivers/net/ethernet/marvell/mvpp2.c      2017-04-03
> 10:45:23.008339453 +0200
> @@ -2997,7 +2997,7 @@
>         struct mvpp2_prs_entry *pe;
>         int tid;
> 
> -       pe = kzalloc(sizeof(*pe), GFP_KERNEL);
> +       pe = kzalloc(sizeof(*pe), GFP_ATOMIC);
>         if (!pe)
>                 return NULL;
>         mvpp2_prs_tcam_lu_set(pe, MVPP2_PRS_LU_MAC);
> @@ -3059,7 +3059,7 @@
>                 if (tid < 0)
>                         return tid;
> 
> -               pe = kzalloc(sizeof(*pe), GFP_KERNEL);
> +               pe = kzalloc(sizeof(*pe), GFP_ATOMIC);
>                 if (!pe)
>                         return -1;
>                 mvpp2_prs_tcam_lu_set(pe, MVPP2_PRS_LU_MAC);

I am wondering if doing a GFP_ATOMIC allocation for this is the right
solution. Should it be pre-allocated instead?

I would have to look at how other drivers typically do this.

Perhaps allocating on the stack is reasonable? After all, sizeof(struct
mvpp2_prs_entry) is only: 4 + 6 * 4 + 4 * 4 = 44 bytes. It's allocated
at the beginning of the function, and freed at the end, so it really
calls for a local variable.

Anyway, I think it's worth investigating a different solution than
blindly converting to a GFP_ATOMIC allocation.

Best regards,

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
