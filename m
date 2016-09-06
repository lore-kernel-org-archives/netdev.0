From: Harini Katakam <harinikatakamlinux@gmail.com>
Subject: Re: [RFC PATCH 2/2] macb: Enable 1588 support in SAMA5D2 platform.
Date: Tue, 6 Sep 2016 13:13:19 +0530
Message-ID: <CAFcVECLWQy-25zjvBa9dVvtCFsgpLcuhOm4sOzKv4qt=+R5-TQ@mail.gmail.com>
References: <1472820817-21874-1-git-send-email-andrei.pistirica@microchip.com> <1472820817-21874-2-git-send-email-andrei.pistirica@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>, davem@davemloft.net,
        Nicolas Ferre <nicolas.ferre@atmel.com>,
        Harini Katakam <harini.katakam@xilinx.com>,
        Punnaiah Choudary Kalluri <punnaia@xilinx.com>,
        "michals@xilinx.com" <michals@xilinx.com>,
        Anirudha Sarangi <anirudh@xilinx.com>,
        Boris Brezillon <boris.brezillon@free-electrons.com>,
        alexandre.belloni@free-electrons.com, tbultel@pixelsurmer.com,
        Richard Cochran <richardcochran@gmail.com>
To: Andrei Pistirica <andrei.pistirica@microchip.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472820817-21874-2-git-send-email-andrei.pistirica@microchip.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrei,

+Richard Cochran

On Fri, Sep 2, 2016 at 6:23 PM, Andrei Pistirica
<andrei.pistirica@microchip.com> wrote:
> Hardware time stamp on the PTP Ethernet packets are received using the
> SO_TIMESTAMPING API. Timers are obtained from the PTP event/peer
> gem registers.
>
> Signed-off-by: Andrei Pistirica <andrei.pistirica@microchip.com>
> ---
> Integration with SAMA5D2 only. This feature wasn't tested on any
> other platform that might use cadence/gem.
>
> Patch is not completely ported to the very latest version of net-next,
> and it will be after review.
>
<snip>
> @@ -853,6 +858,11 @@ static int gem_rx(struct macb *bp, int budget)
>                     GEM_BFEXT(RX_CSUM, ctrl) & GEM_RX_CSUM_CHECKED_MASK)
>                         skb->ip_summed = CHECKSUM_UNNECESSARY;
>
> +/* guard the hot-path */
> +#ifdef CONFIG_MACB_USE_HWSTAMP
> +               if (bp->hwts_rx_en)
> +                       macb_ptp_do_rxstamp(bp, skb);
> +#endif

I'm just wondering if the same #ifdef can be used for timestamping
in all versions of this IP.
As you know, ZynqMP uses the timestamp from BD and older
versions of do not have an indication or extended BD support.
So, it might useful to add a dependency/check on the product family,
through config structure.
That way, both version can use their respective RX timestamp methods
based on the compatible string.
Please let me know if you have any other ideas.

Regards,
Harini
