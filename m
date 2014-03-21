From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH v5] sh_eth: ensure pm_runtime cannot suspend the device
 during init
Date: Fri, 21 Mar 2014 13:14:59 +0100
Message-ID: <CAMuHMdXkdrDKPcFmrBMovh4TWv2CwHUJ14YUhgKYLvwvw_rMhQ@mail.gmail.com>
References: <1395400154-25710-1-git-send-email-ben.dooks@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@lists.codethink.co.uk,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>
To: Ben Dooks <ben.dooks@codethink.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:35858 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934009AbaCUMPA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 08:15:00 -0400
In-Reply-To: <1395400154-25710-1-git-send-email-ben.dooks@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

On Fri, Mar 21, 2014 at 12:09 PM, Ben Dooks <ben.dooks@codethink.co.uk> wrote:
> The pm_rumtime work queue is causing the device to be suspended during
> initialisation, thus the initialisation may not be able to access registers
> properly. As the code is called from a work queue, it is possible that this
> is not seen from certain configurations/builds due to the asynchronos
> nature of the code.
>
> Another issue has also been found where the network device registration
> calls back into the driver thus causing further pm_runtime calls that
> also caused issues with the MDIO bus code. This has now been checked
> and is the only place the MDIO can be called without the device open.
>
> Use pm_runtime_get_sync() and pm_runtime_put() to ensure that the
> pm system does not suspend it during the probe() call and remove the
> now unnecessary pm_runtime_resume() call. Also add a call in the error
> path to call pm_runtime_disable().
>
> This fixes the external abort that can cause /sbin/init or other such
> init processed to die.
>
> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
> Tested-by: Geert Uytterhoeven <geert@linux-m68k.org>

Thanks, still works!

> ---
> Cc: sergei.shtylyov@cogentembedded.com
> Cc: laurent.pinchart+renesas@ideasonboard.com
> cc: netdev@vger.kernel.org
>
> Note, Laurent this should probably be applied before your
> current series as it may require changes to the exit sequence.

I guess this should read:

" Fixed from v4:
          - rebased on top of netdev-next"

?

> Fixes from v1:
>         - use pm_runtime_put() over pm_runtime_put_sync() as
>           we do not need to guaranteed the device has powered
>           off after probe.
>
> Fixed from v2:
>         - call pm_runtime_put() in error path
>
> Fixed from v3:
>         - call pm_runtime_disable() in error path

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
