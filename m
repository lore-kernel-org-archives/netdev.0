From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH 1/4] net: hix5hd2_gmac: add tx scatter-gather feature
Date: Mon, 15 Aug 2016 11:18:19 -0500
Message-ID: <CAL_JsqLgzaPECHdX8yHC3DAUq0jXhgUFE+xVFbeV0OLQXopqxg@mail.gmail.com>
References: <1470906115-155569-1-git-send-email-lidongpo@hisilicon.com>
 <1470906115-155569-2-git-send-email-lidongpo@hisilicon.com>
 <20160812184336.GA5706@rob-hp-laptop> <57B1664F.1090708@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mark Rutland <mark.rutland@arm.com>,
	Michael Turquette <mturquette@baylibre.com>,
	Stephen Boyd <sboyd@codeaurora.org>,
	Russell King <linux@armlinux.org.uk>,
	Zhangfei Gao <zhangfei.gao@linaro.org>,
	Yisen Zhuang <yisen.zhuang@huawei.com>, salil.mehta@huawei.com,
	David Miller <davem@davemloft.net>,
	Arnd Bergmann <arnd@arndb.de>, Andrew Lunn <andrew@lunn.ch>,
	xuejiancheng@hisilicon.com, benjamin.chenhao@hisilicon.com,
	howell.yang@hisilicon.com, netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	linux-clk <linux-clk@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Dongpo Li <lidongpo@hisilicon.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <57B1664F.1090708@hisilicon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 15, 2016 at 1:50 AM, Dongpo Li <lidongpo@hisilicon.com> wrote:
> Hi Rob,
> Many thanks for your review.
>
> On 2016/8/13 2:43, Rob Herring wrote:
>> On Thu, Aug 11, 2016 at 05:01:52PM +0800, Dongpo Li wrote:
>>> From: Li Dongpo <lidongpo@hisilicon.com>
>>>
>>> The "hix5hd2" is SoC name, add the generic ethernet driver name.
>>> The "hisi-gemac-v1" is the basic version and "hisi-gemac-v2" adds
>>> the SG/TXCSUM/TSO/UFO features.
>>> This patch only adds the SG(scatter-gather) driver for transmitting,
>>> the drivers of other features will be submitted later.
>>
>> The compatible string changes should probably be a separate patch.
>>
> ok, I will split this patch into two patches, one for compatible string changes,
> and one for driver feature implementation.
>
>>> Signed-off-by: Dongpo Li <lidongpo@hisilicon.com>
>>> ---
>>>  .../bindings/net/hisilicon-hix5hd2-gmac.txt        |   9 +-
>>>  drivers/net/ethernet/hisilicon/hix5hd2_gmac.c      | 213 +++++++++++++++++++--
>>>  2 files changed, 205 insertions(+), 17 deletions(-)
>>>
>>> diff --git a/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt b/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
>>> index 75d398b..3c02fac 100644
>>> --- a/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
>>> +++ b/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
>>> @@ -1,7 +1,12 @@
>>>  Hisilicon hix5hd2 gmac controller
>>>
>>>  Required properties:
>>> -- compatible: should be "hisilicon,hix5hd2-gmac".
>>> +- compatible: should contain one of the following version strings:
>>> +    * "hisilicon,hisi-gemac-v1"
>>> +    * "hisilicon,hisi-gemac-v2"
>>> +    and one of the following SoC string:
>>> +    * "hisilicon,hix5hd2-gemac"
>>> +    * "hisilicon,hi3798cv200-gemac"
>>
>> Make it clear what the order should be.
>>
> ok, I will put the SoC strings in alphabetical order.

No, I mean the most specific string comes first.

Rob
