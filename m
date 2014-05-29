From: zhangfei <zhangfei.gao@linaro.org>
Subject: Re: [PATCH v2 1/2] Documentation: add Device tree bindings for Hisilicon
 hix5hd2 ethernet
Date: Thu, 29 May 2014 19:52:56 +0800
Message-ID: <53871F98.8070603@linaro.org>
References: <1401194667-14445-1-git-send-email-zhangfei.gao@linaro.org> <1401194667-14445-2-git-send-email-zhangfei.gao@linaro.org> <20140527133423.GB6969@leverpostej> <53857714.3070603@linaro.org> <20140528125354.GA2092@leverpostej> <5385E3CC.9050700@linaro.org> <20140528145804.GA16088@leverpostej>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"arnd@arndb.de" <arnd@arndb.de>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>,
	"David.Laight@ACULAB.COM" <David.Laight@ACULAB.COM>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"haifeng.yan@linaro.org" <haifeng.yan@linaro.org>,
	"jchxue@gmail.com" <jchxue@gmail.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:60412 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932535AbaE2LxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 07:53:10 -0400
Received: by mail-pa0-f47.google.com with SMTP id ld10so245959pab.34
        for <netdev@vger.kernel.org>; Thu, 29 May 2014 04:53:09 -0700 (PDT)
In-Reply-To: <20140528145804.GA16088@leverpostej>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 05/28/2014 10:58 PM, Mark Rutland wrote:
> On Wed, May 28, 2014 at 02:25:32PM +0100, zhangfei wrote:
>>
>>
>> On 05/28/2014 08:53 PM, Mark Rutland wrote:
>>> On Wed, May 28, 2014 at 06:41:40AM +0100, zhangfei wrote:
>>>> Dear Mark
>>>>
>>>> On 05/27/2014 09:34 PM, Mark Rutland wrote:
>>>>> On Tue, May 27, 2014 at 01:44:26PM +0100, Zhangfei Gao wrote:
>>>>>> Signed-off-by: Zhangfei Gao <zhangfei.gao@linaro.org>
>>>>>> ---
>>>>>>     .../bindings/net/hisilicon-hix5hd2-gmac.txt        |   36 ++++++++++++++++++++
>>>>>>     1 file changed, 36 insertions(+)
>>>>>>     create mode 100644 Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
>>>>>>
>>>>>> diff --git a/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt b/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
>>>>>> new file mode 100644
>>>>>> index 0000000..5fe3835
>>>>>> --- /dev/null
>>>>>> +++ b/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
>>>>>> @@ -0,0 +1,36 @@
>>>>>> +Hisilicon hix5hd2 gmac controller
>>>>>
>>>>> Just to clarify, is the SoC name "hix5hd2", or is the 'x' a wildcard?
>>>> "hix5hd2" is Soc name, which contains a series of similar chips.
>>>
>>> How similar are they?
>>>
>>> It's preferable to have a precise name, even when used as a fallback for
>>> other similar devices.
>>
>> The soc name "hix5hd2" is provided by hisilicon.
>> In fact, they have considered a lot and discussed long time for this name :)
>
> Sure, I would not expect hisilicon to rebrand their SoC family due to my
> comments on a mailing list.
>
> w.r.t. naming in the kernel I could only find an unanswered query [1]
> from Olof Johansson earlier this month, and no rationale for the change.
>
> I tried searching online for "hix5hd2" and didn't find much other than a
> suggestion it's also known as "Hi3716cv200". I assume this means the
> Hi371 range in general, which covers a few variants on the hisilicon
> website [2]. The names there are far more specific than "hix5hd2".
>
> We've been bitten in the past when generic SoC family names are used in
> DT bindings without also having specific strings. It's usually better to
> choose a particular variant as the base, and have others claim
> compatibility with that (with additional more specific compatible
> strings).
>
> The key issue is how similar the SoC variants are. If they are identical
> w.r.t. this block and the blocks it is attached to, then the compatible
> string you propose is likely to be fine. However, subtle differences in
> integration across variants might cause issues for which we want
> targeted workarounds, or we might be able to make better use of
> particular variants based on information that we cannot probe from the
> HW. For that we need very specific compatible strings, and in general it
> is better to add those and not need them than to need them but not have
> them.

Currently hix5hd2 is series of hi3716c v200, hi3719c v100, hi3718c v100.
They are same soc, except minus pin assembles different.

However, not all hi37x is in this series, for example hi3716c v100 is a 
different soc.

In the future hi3719m, hi3718m may also plan to add to hix5hd2 series.
The difference will be different cpu core number, different gpu core number.
Also use different ethernet controller.


>>>>>> +
>>>>>> +Required properties:
>>>>>> +- compatible: should be "hisilicon,hix5hd2-gmac".
>>>>>> +- reg: specifies base physical address(s) and size of the device registers.
>>>>>> +  The first region is the MAC register base and size.
>>>>>> +  The second region is external interface control register.
>>>>>
>>>>> Single registers? Are these not part of a larger block?
>>>> It is a single register, outside of the memory region.
>>>> gmac0: reg = <0xf9840000 0x1000>,<0xf984300c 0x4>;
>>>> gmac1: reg = <0xf9841000 0x1000>,<0xf9843010 0x4>;
>>>>
>>>> The register is controlling interface mode, duplex etc.
>>>> In fact it is rather a bug fix to the silicon, when it is added with
>>>> intension of not touching the original ip design.
>>>>
>>>> It may be moved to the memory region in the future silicon design.
>>>> However, currently without such register, it can not work.
>>>
>>> I see. Is it possible that a future revision might have this fixed, such
>>> that the second reg entry would become optional?
>>
>> We have given this feedback to the silicon team, and they admit this
>> should be fixed.
>> However, not sure it can be fixed soon since the product pressure.
>> Can we keep this first since it is required currently.
>
> I'm not asking for its removal, I'm just trying to find out if in future
> we might need to support a DTB without the second entry.
>

Double confirmed with silicon guy, the fix can not be added in this chip.
As the product is stable now, and it is too expensive to make new version.

Thanks
