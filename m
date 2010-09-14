From: Kevin Hilman <khilman@deeprootsystems.com>
Subject: Re: [PATCH 0/9] post cpdma/mdio refactoring fixes
Date: Tue, 14 Sep 2010 11:50:39 -0700
Message-ID: <87hbhsnoqo.fsf@deeprootsystems.com>
References: <1284401251-8846-1-git-send-email-cyril@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com,
	linux-omap@vger.kernel.org, michael.williamson@criticallink.com,
	caglarakyuz@gmail.com, bparrot@ti.com
To: Cyril Chemparathy <cyril@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1284401251-8846-1-git-send-email-cyril@ti.com> (Cyril
	Chemparathy's message of "Mon, 13 Sep 2010 14:07:22 -0400")
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cyril Chemparathy <cyril@ti.com> writes:

> This series consists of fixes for issues found during broader testing of the
> davinci cpdma/mdio separation series.
>
> The fixes included here are:
>
>   1. Ability to force 100/full rather than auto-detect phy.  This is necessary
>      for the external switch on the da830 evm platform
>
>   2. Fix end-of-queue requeue to include checks at submission time (in
>      addition to pre-existing completion time checks).
>
>   3. Cleanups to rx path error handling.  This prevents unnecessary stack
>      dumps for perfectly legal situations.
>
>   4. Work around for emac-soft-reset tie-up to mdio controller.  This affects
>      all da8xx family devices (and possibly am35xx as well).
>
>   5. Reworked hard-coded scan-time estimate to use a more accurate calculated
>      number instead.
>
>   6. Code to generate cpdma register dumps, useful during debug.
>
>
> Many thanks to Mike and Caglar for patiently working with me through these
> issues

Thanks for working with them to resolve these issues.

> I've taken the liberty of adding their sign offs.

A sign-off is only for those on the delivery path of the patch.  Can you
update changing those to Tested-By  tags?

If you prefer, you can respin the original series with these fixes
included instead of creating a separate series.  I will then just drop
the original, and queue the new one.

Thanks,

Kevin

> Cyril Chemparathy (9):
>   net: davinci_emac: allow forced 100/full via phy_id
>   davinci: specify phy_id rather than auto-detect
>   net: davinci_cpdma: requeue on early end-of-queue
>   net: davinci_emac: fix rx error handling
>   net: davinci_mdio: separate out controller reset
>   net: davinci_mdio: use calculated bus access times
>   net: davinci_mdio: work around emac soft-reset during i/o
>   net: davinci_cpdma: add register dump routines
>   net: davinci_emac: extended register dumps on tx timeout
>
>  arch/arm/mach-davinci/board-da830-evm.c    |    2 +
>  arch/arm/mach-davinci/board-da850-evm.c    |    3 +
>  arch/arm/mach-davinci/board-dm365-evm.c    |    4 +
>  arch/arm/mach-davinci/board-dm644x-evm.c   |    3 +
>  arch/arm/mach-davinci/board-dm646x-evm.c   |    5 +
>  arch/arm/mach-davinci/board-mityomapl138.c |    3 +
>  arch/arm/mach-davinci/board-neuros-osd2.c  |    4 +
>  arch/arm/mach-davinci/board-sffsdr.c       |    4 +
>  drivers/net/davinci_cpdma.c                |  132 ++++++++++++++++++-
>  drivers/net/davinci_cpdma.h                |    3 +
>  drivers/net/davinci_emac.c                 |   31 ++++-
>  drivers/net/davinci_mdio.c                 |  195 ++++++++++++++++++++--------
>  include/linux/davinci_emac.h               |    7 +
>  13 files changed, 334 insertions(+), 62 deletions(-)
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-omap" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
