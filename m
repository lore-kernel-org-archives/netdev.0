From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: Re: [PATCH 3/4] net/fec: set phy_speed to the optimal frequency 2.5
 MHz
Date: Tue, 20 Sep 2011 13:10:11 -0700
Message-ID: <4E78F323.1030302@boundarydevices.com>
References: <1316346852-17090-1-git-send-email-shawn.guo@linaro.org> <1316346852-17090-4-git-send-email-shawn.guo@linaro.org> <4E77C4A2.1060802@boundarydevices.com> <20110920025700.GE28084@S2100-06.ap.freescale.net> <4E78F20A.30001@boundarydevices.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org, patches@linaro.org
To: Shawn Guo <shawn.guo@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oproxy1-pub.bluehost.com ([66.147.249.253]:42763 "HELO
	oproxy1-pub.bluehost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750823Ab1ITUKN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2011 16:10:13 -0400
In-Reply-To: <4E78F20A.30001@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/20/2011 1:05 PM, Troy Kisky wrote:
> On 9/19/2011 7:57 PM, Shawn Guo wrote:
>> On Mon, Sep 19, 2011 at 03:39:30PM -0700, Troy Kisky wrote:
>>> On 9/18/2011 4:54 AM, Shawn Guo wrote:
>>>> With the unnecessary 1 bit left-shift on fep->phy_speed during the
>>>> calculation, the phy_speed always runs at the half frequency of the
>>>> optimal one 2.5 MHz.
>>>>
>>>> The patch removes that 1 bit left-shift to get the optimal phy_speed.
>>>>
>>>> Signed-off-by: Shawn Guo<shawn.guo@linaro.org>
>>>> ---
>>>>   drivers/net/fec.c |    2 +-
>>>>   1 files changed, 1 insertions(+), 1 deletions(-)
>>>>
>>>> diff --git a/drivers/net/fec.c b/drivers/net/fec.c
>>>> index 5ef0e34..04206e4 100644
>>>> --- a/drivers/net/fec.c
>>>> +++ b/drivers/net/fec.c
>>>> @@ -1007,7 +1007,7 @@ static int fec_enet_mii_init(struct 
>>>> platform_device *pdev)
>>>>       /*
>>>>        * Set MII speed to 2.5 MHz (= clk_get_rate() / 2 * phy_speed)
>>>>        */
>>>> -    fep->phy_speed = DIV_ROUND_UP(clk_get_rate(fep->clk), 
>>>> 5000000)<<   1;
>>>> +    fep->phy_speed = DIV_ROUND_UP(clk_get_rate(fep->clk), 5000000);
>>>>       writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
>>>>
>>>>       fep->mii_bus = mdiobus_alloc();
>>> Do you need to round up to an even value? Is the hardware
>>> documentation wrong?
>> The round up is something existed, and the patch does not touch that
>> part.
> That's not what I was referring to. Previously, phy_speed was always 
> even because of the shift.
> The MX53 manual says this field starts at bit 1, and bit 0 is unused. 
> Therefore, maybe the
> correct change would be
>
> fep->phy_speed = DIV_ROUND_UP(clk_get_rate(fep->clk), 2500000)<<   1;

oops, I meant
fep->phy_speed = DIV_ROUND_UP(clk_get_rate(fep->clk), 2500000 * 4) <<   1;
> So, the question is, does this field start at bit 0 (your version is 
> correct)
> or bit 1? In other words, how did the hardware manual get it wrong? 
> Wrong starting
> bit, or divide by 2 not needed. Please document the mistake in the code.
>
>
>>
>>> Does this need a quirk? What boards has this been verified to fix?
>>>
>> I tested this on i.mx28, i.mx53 and i.mx6q.  Do you see problem on
>> your platform?
>>
> I have not tested yet, but will sometime this week.
>
>
>
