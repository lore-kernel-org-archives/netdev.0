From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 1/5] temac: Add Virtex4 address mappings
Date: Mon, 22 Feb 2010 15:10:39 -0700
Message-ID: <fa686aa41002221410y41886d50r8d657bc88b8ddbc8@mail.gmail.com>
References: <1266865621-28955-1-git-send-email-gfilip@ee.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: gfilip@ee.ethz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f197.google.com ([209.85.211.197]:32973 "EHLO
	mail-yw0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754498Ab0BVWTQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2010 17:19:16 -0500
Received: by ywh35 with SMTP id 35so1484886ywh.4
        for <netdev@vger.kernel.org>; Mon, 22 Feb 2010 14:19:16 -0800 (PST)
In-Reply-To: <1266865621-28955-1-git-send-email-gfilip@ee.ethz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 22, 2010 at 12:06 PM,  <gfilip@ee.ethz.ch> wrote:
> This patch belongs to a set of patches which extends the temac driver=
 to support Virtex4-FX. It was successfully tested on the ML403 evaluat=
ion board.
>
> Signed-off-by: Filip Gospodinov <gfilip@ee.ethz.ch>
> ---
> =A0drivers/net/ll_temac.h | =A0 46 ++++++++++++++++++++++++++++++++++=
++++++++++++
> =A01 files changed, 46 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/ll_temac.h b/drivers/net/ll_temac.h
> index 1af66a1..95dd650 100644
> --- a/drivers/net/ll_temac.h
> +++ b/drivers/net/ll_temac.h
> @@ -56,7 +56,52 @@ This option defaults to enabled (set) */
> =A0 =A0 =A0 =A0 XTE_OPTION_RXEN)
>
> =A0/* XPS_LL_TEMAC SDMA registers definition */
> +#ifdef CONFIG_XILINX_VIRTEX_4_FX
> +#define TX_NXTDESC_PTR =A0 =A0 =A00x00 =A0 =A0 =A0 =A0 =A0 =A0/* r *=
/
> +#define TX_CURBUF_ADDR =A0 =A0 =A00x04 =A0 =A0 =A0 =A0 =A0 =A0/* r *=
/
> +#define TX_CURBUF_LENGTH =A0 =A00x08 =A0 =A0 =A0 =A0 =A0 =A0/* r */
> +#define TX_CURDESC_PTR =A0 =A0 =A00x0C =A0 =A0 =A0 =A0 =A0 =A0/* rw =
*/
> +#define TX_TAILDESC_PTR =A0 =A0 0x10 =A0 =A0 =A0 =A0 =A0 =A0/* rw */
> +#define TX_CHNL_CTRL =A0 =A0 =A0 =A00x14 =A0 =A0 =A0 =A0 =A0 =A0/* r=
w */
> +#define CHNL_CTRL_IRQ_IOE =A0 =A0 =A0 (1 << 9)
> +#define CHNL_CTRL_IRQ_EN =A0 =A0 =A0 =A0(1 << 7)
> +#define CHNL_CTRL_IRQ_ERR_EN =A0 =A0(1 << 2)
> +#define CHNL_CTRL_IRQ_DLY_EN =A0 =A0(1 << 1)
> +#define CHNL_CTRL_IRQ_COAL_EN =A0 (1 << 0)
> +#define TX_IRQ_REG =A0 =A0 =A0 =A0 =A00x18 =A0 =A0 =A0 =A0 =A0 =A0/*=
 rw */
> +#define TX_CHNL_STS =A0 =A0 =A0 =A0 0x1C =A0 =A0 =A0 =A0 =A0 =A0/* r=
 */
> +#define RX_NXTDESC_PTR =A0 =A0 =A00x20 =A0 =A0 =A0 =A0 =A0 =A0/* r *=
/
> +#define RX_CURBUF_ADDR =A0 =A0 =A00x24 =A0 =A0 =A0 =A0 =A0 =A0/* r *=
/
> +#define RX_CURBUF_LENGTH =A0 =A00x28 =A0 =A0 =A0 =A0 =A0 =A0/* r */
> +#define RX_CURDESC_PTR =A0 =A0 =A00x2C =A0 =A0 =A0 =A0 =A0 =A0/* rw =
*/
> +#define RX_TAILDESC_PTR =A0 =A0 0x30 =A0 =A0 =A0 =A0 =A0 =A0/* rw */
> +#define RX_CHNL_CTRL =A0 =A0 =A0 =A00x34 =A0 =A0 =A0 =A0 =A0 =A0/* r=
w */
> +#define RX_IRQ_REG =A0 =A0 =A0 =A0 =A00x38 =A0 =A0 =A0 =A0 =A0 /* rw=
 */
> +#define IRQ_COAL =A0 =A0 =A0 =A0(1 << 0)
> +#define IRQ_DLY =A0 =A0 =A0 =A0 (1 << 1)
> +#define IRQ_ERR =A0 =A0 =A0 =A0 (1 << 2)
> +#define IRQ_DMAERR =A0 =A0 =A0(1 << 7) =A0 =A0 =A0 =A0 =A0 =A0/* thi=
s is not documented ??? */
> +#define RX_CHNL_STS =A0 =A0 =A0 =A0 0x3C =A0 =A0 =A0 =A0/* r */
> +#define CHNL_STS_ENGBUSY =A0 =A0(1 << 1)
> +#define CHNL_STS_EOP =A0 =A0 =A0 =A0(1 << 2)
> +#define CHNL_STS_SOP =A0 =A0 =A0 =A0(1 << 3)
> +#define CHNL_STS_CMPLT =A0 =A0 =A0(1 << 4)
> +#define CHNL_STS_SOE =A0 =A0 =A0 =A0(1 << 5)
> +#define CHNL_STS_IOE =A0 =A0 =A0 =A0(1 << 6)
> +#define CHNL_STS_ERR =A0 =A0 =A0 =A0(1 << 7)
> +
> +#define CHNL_STS_BSYWR =A0 =A0 =A0(1 << 16)
> +#define CHNL_STS_CURPERR =A0 =A0(1 << 17)
> +#define CHNL_STS_NXTPERR =A0 =A0(1 << 18)
> +#define CHNL_STS_ADDRERR =A0 =A0(1 << 19)
> +#define CHNL_STS_CMPERR =A0 =A0 (1 << 20)
> +#define CHNL_STS_TAILERR =A0 =A0(1 << 21)
> +
> +#define DMA_CONTROL_REG =A0 =A0 =A0 =A0 =A0 =A0 0x40 =A0 =A0 =A0 =A0=
 =A0 =A0/* rw */
> +#define DMA_CONTROL_RST =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1 << 0)
> +#define DMA_TAIL_ENABLE =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1 << 2)
>

Oh, ugly.  The register definitions are identical for virtex4 mmio
access and virtex5 DCR access.  The only difference is the multiplier
(DCRs increase by 1, mmio increments by 4) to the register.  Rather
than defining a whole new register block, just multiply the offset by
4 when doing an MMIO access.

g.
