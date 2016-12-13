From: Dongpo Li <lidongpo@hisilicon.com>
Subject: Re: [PATCH v2 1/4] net: hix5hd2_gmac: add generic compatible string
Date: Tue, 13 Dec 2016 10:02:30 +0800
Message-ID: <584F56B6.60905@hisilicon.com>
References: <1480944481-118803-1-git-send-email-lidongpo@hisilicon.com>
 <1480944481-118803-2-git-send-email-lidongpo@hisilicon.com>
 <20161209223521.5dnj7l44e663sntl@rob-hp-laptop>
 <584E871D.7060200@hisilicon.com>
 <CAL_Jsq+d5xHsxMKxbWSYy3cDXnC+HQj3=wun1zxf5PZ_BYrD-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>,
        Michael Turquette <mturquette@baylibre.com>,
        Stephen Boyd <sboyd@codeaurora.org>,
        Russell King <linux@armlinux.org.uk>,
        Zhangfei Gao <zhangfei.gao@linaro.org>,
        Yisen Zhuang <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, David Miller <davem@davemloft.net>,
        Arnd Bergmann <arnd@arndb.de>, Andrew Lunn <andrew@lunn.ch>,
        Jiancheng Xue <xuejiancheng@hisilicon.com>,
        <benjamin.chenhao@hisilicon.com>, <caizhiyong@hisilicon.com>,
        netdev <netdev@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Rob Herring <robh@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAL_Jsq+d5xHsxMKxbWSYy3cDXnC+HQj3=wun1zxf5PZ_BYrD-Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016/12/12 22:21, Rob Herring wrote:
> On Mon, Dec 12, 2016 at 5:16 AM, Dongpo Li <lidongpo@hisilicon.com> wrote:
>> Hi Rob,
>>
>> On 2016/12/10 6:35, Rob Herring wrote:
>>> On Mon, Dec 05, 2016 at 09:27:58PM +0800, Dongpo Li wrote:
>>>> The "hix5hd2" is SoC name, add the generic ethernet driver name.
>>>> The "hisi-gemac-v1" is the basic version and "hisi-gemac-v2" adds
>>>> the SG/TXCSUM/TSO/UFO features.
>>>>
>>>> Signed-off-by: Dongpo Li <lidongpo@hisilicon.com>
>>>> ---
>>>>  .../devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt    |  9 +++++++--
>>>>  drivers/net/ethernet/hisilicon/hix5hd2_gmac.c             | 15 +++++++++++----
>>>>  2 files changed, 18 insertions(+), 6 deletions(-)
>>>>
>>>> diff --git a/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt b/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
>>>> index 75d398b..75920f0 100644
>>>> --- a/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
>>>> +++ b/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
>>>> @@ -1,7 +1,12 @@
>>>>  Hisilicon hix5hd2 gmac controller
>>>>
>>>>  Required properties:
>>>> -- compatible: should be "hisilicon,hix5hd2-gmac".
>>>> +- compatible: should contain one of the following SoC strings:
>>>> +    * "hisilicon,hix5hd2-gemac"
>>>> +    * "hisilicon,hi3798cv200-gemac"
>>>> +    and one of the following version string:
>>>> +    * "hisilicon,hisi-gemac-v1"
>>>> +    * "hisilicon,hisi-gemac-v2"
>>>
>>> What combinations are valid? I assume both chips don't have both v1 and
>>> v2. 2 SoCs and 2 versions so far, I don't think there is much point to
>>> have the v1 and v2 compatible strings.
>>>
>> The v1 and v2 are generic MAC compatible strings, many HiSilicon SoCs may
>> use the same MAC version. For example,
>> hix5hd2, hi3716cv200 SoCs use the v1 MAC version,
>> hi3798cv200, hi3516a SoCs use the v2 MAC version,
>> and there may be more SoCs added in future.
>> So I think the generic compatible strings are okay here.
>> Should I add the hi3716cv200, hi3516a SoCs compatible here?
> 
> Yes.
> 
>> Do you have any good advice?
>>
>>>>  - reg: specifies base physical address(s) and size of the device registers.
>>>>    The first region is the MAC register base and size.
>>>>    The second region is external interface control register.
>>>> @@ -20,7 +25,7 @@ Required properties:
>>>>
>>>>  Example:
>>>>      gmac0: ethernet@f9840000 {
>>>> -            compatible = "hisilicon,hix5hd2-gmac";
>>>> +            compatible = "hisilicon,hix5hd2-gemac", "hisilicon,hisi-gemac-v1";
>>>
>>> You can't just change compatible strings.
>>>
>> Okay, maybe I should name all the compatible string with the suffix "-gmac" instead of
>> "-gemac". This can keep the compatible strings with the same suffix. Is this okay?
>> Can I just add the generic compatible string without changing the SoCs compatible string?
>> Like following:
>>         gmac0: ethernet@f9840000 {
>>  -              compatible = "hisilicon,hix5hd2-gmac";
>>  +              compatible = "hisilicon,hix5hd2-gmac", "hisilicon,hisi-gmac-v1";
> 
> Yes, this is fine.
> 
Many thanks for your advice.
As the patch series have been applied to net-next branch,
in which way should I commit this compatible fix?
Should I send a new patch with "Fixes: xxxx"?


    Regards,
    Dongpo

.
