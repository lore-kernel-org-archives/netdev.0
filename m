From: John Williams <john.williams@petalogix.com>
Subject: Re: [PATCH 1/2] net: ll_temac: fix interrupt bug when interrupt 0 is
	used
Date: Thu, 27 May 2010 14:12:18 +1000
Message-ID: <AANLkTin0Lg8HCpCAmyy_ybPlv6K9_iyE2aFrhifw486D@mail.gmail.com>
References: <6f264a7a-e5da-494a-a24d-1578ca422807@VA3EHSMHS016.ehs.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	grant.likely@secretlab.ca, jwboyer@linux.vnet.ibm.com,
	michal.simek@petalogix.com, Brian Hill <brian.hill@xilinx.com>
To: John Linn <john.linn@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:56530 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750756Ab0E0EMU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 00:12:20 -0400
Received: by vws9 with SMTP id 9so4973892vws.19
        for <netdev@vger.kernel.org>; Wed, 26 May 2010 21:12:19 -0700 (PDT)
In-Reply-To: <6f264a7a-e5da-494a-a24d-1578ca422807@VA3EHSMHS016.ehs.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 27, 2010 at 3:29 AM, John Linn <john.linn@xilinx.com> wrote=
:
> The code is not checking the interrupt for DMA correctly so that an
> interrupt number of 0 will cause a false error.
>
> Signed-off-by: Brian Hill <brian.hill@xilinx.com>
> Signed-off-by: John Linn <john.linn@xilinx.com>
> ---
> =A0drivers/net/ll_temac_main.c | =A0 =A02 +-
> =A01 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.=
c
> index fa7620e..0615737 100644
> --- a/drivers/net/ll_temac_main.c
> +++ b/drivers/net/ll_temac_main.c
> @@ -950,7 +950,7 @@ temac_of_probe(struct of_device *op, const struct=
 of_device_id *match)
>
> =A0 =A0 =A0 =A0lp->rx_irq =3D irq_of_parse_and_map(np, 0);
> =A0 =A0 =A0 =A0lp->tx_irq =3D irq_of_parse_and_map(np, 1);
> - =A0 =A0 =A0 if (!lp->rx_irq || !lp->tx_irq) {
> + =A0 =A0 =A0 if ((lp->rx_irq =3D=3D NO_IRQ) || (lp->tx_irq =3D=3D NO=
_IRQ)) {

Personally I think this is the right thing to do.  But, I thought the
IRQ 0 =3D=3D NO_IRQ (AKA "all-the-world's-an-x86-and-if-not-it-should-b=
e")
holy war was already fought and won (or lost, depending on your
perspective)?

I seem to recall giving reluctant assent to a patch from Grant a few
months ago that touched MicroBlaze thus?

John
