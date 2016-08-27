From: Rami Rosen <roszenrami@gmail.com>
Subject: Re: [PATCH] [v9] net: emac: emac gigabit ethernet controller driver
Date: Sat, 27 Aug 2016 23:26:11 +0300
Message-ID: <CAKoUAr=Z56VxzW=zHu7r9ossdXHQ6xpeYdR5jwhv38zkV_eKFQ@mail.gmail.com>
References: <1472161143-26417-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, devicetree@vger.kernel.org,
        linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
        shankerd@codeaurora.org, vikrams@codeaurora.org,
        cov@codeaurora.org, gavidov@codeaurora.org, robh+dt@kernel.org,
        andrew@lunn.ch, bjorn.andersson@linaro.org, mlangsdo@redhat.com,
        jcm@redhat.com, agross@codeaurora.org,
        David Miller <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>, LinoSanfilippo@gmx.de
To: Timur Tabi <timur@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:34095 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751194AbcH0U0O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 Aug 2016 16:26:14 -0400
In-Reply-To: <1472161143-26417-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Shouldn't it be obj-$(CONFIG_QCOM_EMAC) instead obj-y? QCOM_EMAC is defined as
tristate in the drivers/net/ethernet/qualcomm/Kconfig by this patch,
so it should be possible to build it as a *.ko module also.

> diff --git a/drivers/net/ethernet/qualcomm/emac/Makefile b/drivers/net/ethernet/qualcomm/emac/Makefile
> new file mode 100644
> index 0000000..700ee6e
> --- /dev/null
> +++ b/drivers/net/ethernet/qualcomm/emac/Makefile
> @@ -0,0 +1,7 @@
> +#
> +# Makefile for the Qualcomm Technologies, Inc. EMAC Gigabit Ethernet driver
> +#
> +
> +obj-y += qcom-emac.o
> +


The return type of the method emac_tx_tpd_create()  should be void, as
it always returns true.

> +/* Produce new transmit descriptor */
> +static bool emac_tx_tpd_create(struct emac_adapter *adpt,
> +                              struct emac_tx_queue *tx_q, struct emac_tpd *tpd)
> +{
> +       u32 *hw_tpd;
> +
> +       tx_q->tpd.last_produce_idx = tx_q->tpd.produce_idx;
> +       hw_tpd = EMAC_TPD(tx_q, adpt->tpd_size, tx_q->tpd.produce_idx);
> +
> +       if (++tx_q->tpd.produce_idx == tx_q->tpd.count)
> +               tx_q->tpd.produce_idx = 0;
> +
> +       *(hw_tpd++) = tpd->word[0];
> +       *(hw_tpd++) = tpd->word[1];
> +       *(hw_tpd++) = tpd->word[2];
> +       *hw_tpd = tpd->word[3];
> +
> +       return true;
> +}

...
...
...

Seems that there are several unused members in the emac_stats struct:

> +struct emac_stats {
...
...
Both rx_bcast_byte_cnt and rx_mcast_byte_cnt are not used anywhere/
> +       u64 rx_bcast_byte_cnt;  /* broadcast packets byte count (without FCS) */
> +       u64 rx_mcast_byte_cnt;  /* multicast packets byte count (without FCS) */
...
rx_err_addr is not used
> +       u64 rx_err_addr;        /* packets dropped due to address filtering */

Typo: it is jabbers and not jubbers; greppping for "jubber" under
drivers/net/ethernet gives
0 results, whereas:
/net-next/drivers/net/ethernet$ grep -R jabber | wc -l
gives 241 results.

> +       u64 rx_jubbers;         /* jubbers */


...
..
tx_rd_eop and tx_len_err are not used
> +       u64 tx_rd_eop;          /* count of reads beyond EOP */
> +       u64 tx_len_err;         /* packets with length mismatch */

Both tx_bcast_byte and tx_mcast_byte are not used.
> +       u64 tx_bcast_byte;      /* broadcast packets byte count (without FCS) */
> +       u64 tx_mcast_byte;      /* multicast packets byte count (without FCS) */

Thanks for your good work, it seems that the driver is almost done!


Regards,
Rami Rosen
