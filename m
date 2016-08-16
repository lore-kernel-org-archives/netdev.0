From: Dongpo Li <lidongpo-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Subject: Re: [PATCH 1/4] net: hix5hd2_gmac: add tx scatter-gather feature
Date: Tue, 16 Aug 2016 10:28:12 +0800
Message-ID: <57B27A3C.5070403@hisilicon.com>
References: <1470906115-155569-1-git-send-email-lidongpo@hisilicon.com>
 <1470906115-155569-2-git-send-email-lidongpo@hisilicon.com>
 <20160812184336.GA5706@rob-hp-laptop> <57B1664F.1090708@hisilicon.com>
 <CAL_JsqLgzaPECHdX8yHC3DAUq0jXhgUFE+xVFbeV0OLQXopqxg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Michael Turquette <mturquette-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
	Stephen Boyd <sboyd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Russell King <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
	Zhangfei Gao <zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Yisen Zhuang <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
	<xuejiancheng-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <benjamin.chenhao-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>,
	<howell.yang-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-clk <linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAL_JsqLgzaPECHdX8yHC3DAUq0jXhgUFE+xVFbeV0OLQXopqxg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 2016/8/16 0:18, Rob Herring wrote:
> On Mon, Aug 15, 2016 at 1:50 AM, Dongpo Li <lidongpo-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org> wrote:
>> Hi Rob,
>> Many thanks for your review.
>>
>> On 2016/8/13 2:43, Rob Herring wrote:
>>> On Thu, Aug 11, 2016 at 05:01:52PM +0800, Dongpo Li wrote:
>>>> From: Li Dongpo <lidongpo-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
>>>>
>>>> The "hix5hd2" is SoC name, add the generic ethernet driver name.
>>>> The "hisi-gemac-v1" is the basic version and "hisi-gemac-v2" adds
>>>> the SG/TXCSUM/TSO/UFO features.
>>>> This patch only adds the SG(scatter-gather) driver for transmitting,
>>>> the drivers of other features will be submitted later.
>>>
>>> The compatible string changes should probably be a separate patch.
>>>
>> ok, I will split this patch into two patches, one for compatible string changes,
>> and one for driver feature implementation.
>>
>>>> Signed-off-by: Dongpo Li <lidongpo-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
>>>> ---
>>>>  .../bindings/net/hisilicon-hix5hd2-gmac.txt        |   9 +-
>>>>  drivers/net/ethernet/hisilicon/hix5hd2_gmac.c      | 213 +++++++++++++++++++--
>>>>  2 files changed, 205 insertions(+), 17 deletions(-)
>>>>
>>>> diff --git a/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt b/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
>>>> index 75d398b..3c02fac 100644
>>>> --- a/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
>>>> +++ b/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
>>>> @@ -1,7 +1,12 @@
>>>>  Hisilicon hix5hd2 gmac controller
>>>>
>>>>  Required properties:
>>>> -- compatible: should be "hisilicon,hix5hd2-gmac".
>>>> +- compatible: should contain one of the following version strings:
>>>> +    * "hisilicon,hisi-gemac-v1"
>>>> +    * "hisilicon,hisi-gemac-v2"
>>>> +    and one of the following SoC string:
>>>> +    * "hisilicon,hix5hd2-gemac"
>>>> +    * "hisilicon,hi3798cv200-gemac"
>>>
>>> Make it clear what the order should be.
>>>
>> ok, I will put the SoC strings in alphabetical order.
> 
> No, I mean the most specific string comes first.
> 
ok, I will fix it in next patch version. Thank you.

> Rob
> 
> .
> 


    Regards,
    Dongpo

.

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
