From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH] [V3] Add non-Virtex5 support for LL TEMAC driver
Date: Mon, 5 Apr 2010 18:08:33 -0600
Message-ID: <l2hfa686aa41004051708h1abd23b1qe52d06731089764c@mail.gmail.com>
References: <d9134316-bd07-46a8-91d4-c30f27baeb60@SG2EHSMHS007.ehs.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	jwboyer@linux.vnet.ibm.com, john.williams@petalogix.com,
	michal.simek@petalogix.com, John Tyner <jtyner@cs.ucr.edu>,
	David Miller <davem@davemloft.net>
To: John Linn <john.linn@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:51440 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755264Ab0DFAIy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 20:08:54 -0400
Received: by gwb19 with SMTP id 19so1464673gwb.19
        for <netdev@vger.kernel.org>; Mon, 05 Apr 2010 17:08:53 -0700 (PDT)
In-Reply-To: <d9134316-bd07-46a8-91d4-c30f27baeb60@SG2EHSMHS007.ehs.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 5, 2010 at 3:11 PM, John Linn <john.linn@xilinx.com> wrote:
> This patch adds support for using the LL TEMAC Ethernet driver on
> non-Virtex 5 platforms by adding support for accessing the Soft DMA
> registers as if they were memory mapped instead of solely through the
> DCR's (available on the Virtex 5).
>
> The patch also updates the driver so that it runs on the MicroBlaze.
> The changes were tested on the PowerPC 440, PowerPC 405, and the
> MicroBlaze platforms.
>
> Signed-off-by: John Tyner <jtyner@cs.ucr.edu>
> Signed-off-by: John Linn <john.linn@xilinx.com>
>
> ---
>
> V2 - Incorporated comments from Grant and added more logic to allow t=
he driver
> to work on MicroBlaze.
>
> V3 - Only updated it to apply to head, minor change to include slab.h=
=2E Also
> verified that it now builds for MicroBlaze. Retested on PowerPC and M=
icroBlaze.
> ---
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 | =A0 =A01 -
> =A0drivers/net/ll_temac.h =A0 =A0 =A0| =A0 17 +++++-
> =A0drivers/net/ll_temac_main.c | =A0124 +++++++++++++++++++++++++++++=
+++++---------
> =A03 files changed, 113 insertions(+), 29 deletions(-)
>
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 0ba5b8e..17044dc 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2435,7 +2435,6 @@ config MV643XX_ETH
> =A0config XILINX_LL_TEMAC
> =A0 =A0 =A0 =A0tristate "Xilinx LL TEMAC (LocalLink Tri-mode Ethernet=
 MAC) driver"
> =A0 =A0 =A0 =A0select PHYLIB
> - =A0 =A0 =A0 depends on PPC_DCR_NATIVE
> =A0 =A0 =A0 =A0help
> =A0 =A0 =A0 =A0 =A0This driver supports the Xilinx 10/100/1000 LocalL=
ink TEMAC
> =A0 =A0 =A0 =A0 =A0core used in Xilinx Spartan and Virtex FPGAs


This still at the very least needs to depend on CONFIG_OF.  Otherwise
allmodconfig and allyesconfig on x86 and others will break.  The
driver also doesn't build on sparc, so you'll need to either exclude
CONFIG_SPARC or depend on (PPC || MICROBLAZE) too.

g.

--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
