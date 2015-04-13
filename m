From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH resend] Renesas Ethernet AVB driver
Date: Mon, 13 Apr 2015 23:23:26 +0300
Message-ID: <552C25BE.3070606@cogentembedded.com>
References: <2926619.fiYHPz1IBk@wasted.cogentembedded.com> <20150328082853.GA4255@localhost.localdomain> <5519D380.6070200@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, devicetree@vger.kernel.org,
	galak@codeaurora.org, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	masaru.nagai.vx@renesas.com
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <5519D380.6070200@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 03/31/2015 01:51 AM, Sergei Shtylyov wrote:

>>> Ethernet AVB includes an Gigabit Ethernet controller (E-MAC) that is basically
>>> compatible with SuperH Gigabit Ethernet E-MAC). Ethernet AVB  has a dedicated
>>> direct memory access controller (AVB-DMAC) that is a new design compared to
>>> the
>>> SuperH E-DMAC. The AVB-DMAC is compliant with 3 standards formulated for IEEE
>>> 802.1BA: IEEE 802.1AS timing and synchronization protocol, IEEE 802.1Qav real-
>>> time transfer, and the IEEE 802.1Qat stream reservation protocol.

>>> The driver only supports device tree probing, so the binding document is
>>> included in this patch.

>>> Based on the patches by Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com> and
>>> Masaru Nagai <masaru.nagai.vx@renesas.com>.

>>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

[...]

>>> Index: net-next/drivers/net/ethernet/renesas/ravb.c
>>> ===================================================================
>>> --- /dev/null
>>> +++ net-next/drivers/net/ethernet/renesas/ravb.c
>>> @@ -0,0 +1,3071 @@
[...]

>>> +/* There is CPU dependent code */
>>> +static int ravb_wait_clear(struct net_device *ndev, u16 reg, u32 bits)
>>> +{
>>> +    int i;
>>> +
>>> +    for (i = 0; i < 100; i++) {
>>> +        if (!(ravb_read(ndev, reg) & bits))
>>> +            break;
>>> +        mdelay(1);
>>> +    }
>>> +    if (i >= 100)
>>> +        return -ETIMEDOUT;
>>> +
>>> +    return 0;
>>> +}
>>> +
>>> +static int ravb_wait_setting(struct net_device *ndev, u16 reg, u32 bits)
>>> +{

>> This function is identical to the previous one.

>     It is not, the *break* condition is different. I'll look into merging them
> though...

    Done.

[...]

>>> +/* Caller must hold the lock */
>>> +static void ravb_ptp_update_compare(struct ravb_private *priv, u32 ns)
>>> +{
>>> +    struct net_device *ndev = priv->ndev;
>>> +    /* When the comparison value (GPTC.PTCV) is in range of
>>> +     * [x-1 to x+1] (x is the configured increment value in
>>> +     * GTI.TIV), it may happen that a comparison match is
>>> +     * not detected when the timer wraps around.
>>> +     */

>> What does this funtion do, exactly?

    Loads the new timer comparator value, apparenlty.

>  This looks very fishy to me.

>     Perhaps a workaround for an errata I don't know about.

    Or perhaps it's to keep the comparison value between x and 2**32 - x 
(where x is increment in ns) as required by the manual?

> Nagai-san, could you maybe elaborate?

[...]

>>> +static bool ravb_ptp_is_config(struct ravb_private *priv)
>>> +{

>> This is a bit hacky.  Can't your driver make sure that the HW is ready?

>     Will look into this. Perhaps it's a remainder from when the PTP driver was
> separate...

    No, we enter this mode upon closing the Ethernet device and when the ring 
DMA sizes are changed. Seems unavoidable...

>>> +    if (ravb_read(priv->ndev, CSR) & CSR_OPS_CONFIG)
>>> +        return true;
>>> +    else
>>> +        return false;
>>> +}
>>> +

[...]

WBR, Sergei

