From: Harini Katakam <harinikatakamlinux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [net-next PATCH v2 2/3] net: macb: Add support for jumbo frames
Date: Tue, 5 May 2015 09:51:41 +0530
Message-ID: <CAFcVECLkV=UKUD8T0dytdhqOZBU3MkWGPCqdFm9rfoS-FmEr1g@mail.gmail.com>
References: <1430725960-8441-1-git-send-email-harinik@xilinx.com>
	<b7d968f7-1eb8-4a37-ae28-e7b841d6b178@BY2FFO11FD038.protection.gbl>
	<5547C23B.2080509@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Harini Katakam <harini.katakam-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	"ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org" <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	boris.brezillon-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org,
	alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Punnaiah Choudary Kalluri <punnaia-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	"michals-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org" <michals-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
To: Jaeden Amero <jaeden.amero-acOepvfBmUk@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5547C23B.2080509-acOepvfBmUk@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

On Tue, May 5, 2015 at 12:32 AM, Jaeden Amero <jaeden.amero-acOepvfBmUk@public.gmane.org> wrote:
> On 05/04/2015 02:52 AM, Harini Katakam wrote:
>> Check for "cdns,zynqmp-gem" compatible string and enable jumbo frame support
>> in NWCFG register, update descriptor length masks and registers accordingly.
>> Jumbo max length register should be set according to support in SoC; it is
>> set to 10240 for Zynq Ultrascale+ MPSoC.
>>
>> Signed-off-by: Harini Katakam <harinik-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
>> Reviewed-by: Punnaiah Choudary Kalluri <punnaia-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
>> ---
>>
>> On v1, Michal commented that I should use macb_config for jumbo parameters
>> instead of defining them by reading the compatible string directly.
>> I can use .caps for isjumbo. But jumbo-max-length needs to be defined.
>> Can I add this to the structure? Any suggestions on how to handle this?
>>
>> v2:
>> Add constant definition and update SoC name
>>
>> ---
>>  drivers/net/ethernet/cadence/macb.c |   21 ++++++++++++++++++---
>>  drivers/net/ethernet/cadence/macb.h |    8 ++++++++
>>  2 files changed, 26 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
<snip>
>> @@ -2762,6 +2772,11 @@ static int macb_probe(struct platform_device *pdev)
>>       bp->pclk = pclk;
>>       bp->hclk = hclk;
>>       bp->tx_clk = tx_clk;
>> +     if (of_device_is_compatible(pdev->dev.of_node, "cdns,zynqmp-gem")) {
>> +             bp->isjumbo = 1;
>> +             bp->jumbo_max_len = GEM_ZYNQMP_JUMBO_MAX;
>
> Could you use the bottom 16 bits of DCFG2 instead of GEM_ZYNQMP_JUMBO_MAX?

The bottom 16 bits are 0x3FFF but the ZynqMP SoC actually supports
only upto 10K (0x2800).

Regards,
Harini
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
