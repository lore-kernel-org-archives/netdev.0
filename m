From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH v2 0/2] remove dwc_eth_qos and rename stmicro/stmmac
Date: Wed, 11 Jan 2017 14:54:53 +0000
Message-ID: <1329f5a9-42e2-e44e-8be5-af5ca4cebfbd@synopsys.com>
References: <cover.1484059674.git.jpinto@synopsys.com>
 <0dcdcb5f-200b-b130-9a67-774639353114@st.com>
 <298670a0-7074-a590-9498-7a9db68d499e@synopsys.com>
 <d814eabb-ec19-9df4-1f44-4405ece6995f@st.com>
 <a91d92f0-21a5-2225-88c3-162c8fb005f5@synopsys.com>
 <8bdb613c-36d3-811f-6300-9c97110c855d@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <lars.persson@axis.com>, <niklass@axis.com>,
        <peppe.cavallaro@st.com>, <netdev@vger.kernel.org>
To: Alexandre Torgue <alexandre.torgue@st.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay2.synopsys.com ([198.182.60.111]:32896 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932151AbdAKOy6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 09:54:58 -0500
In-Reply-To: <8bdb613c-36d3-811f-6300-9c97110c855d@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Às 2:39 PM de 1/11/2017, Alexandre Torgue escreveu:
> 
> 
> On 01/11/2017 03:29 PM, Joao Pinto wrote:
>>
>> Alex,
>>
>> Às 2:25 PM de 1/11/2017, Alexandre Torgue escreveu:
>>> Jao,
>>>
>>> On 01/11/2017 12:54 PM, Joao Pinto wrote:
>>>>
>>>> Hi Alex,
>>>>
>>>> Às 11:39 AM de 1/11/2017, Alexandre Torgue escreveu:
>>>>> Hi Jao,
>>>>>
>>>>> On 01/10/2017 03:52 PM, Joao Pinto wrote:
>>>>>> This patch set removes the synopsys/dwc_eth_qos since it was merged recently
>>>>>> to stmmac (dwmac-dwc-qos-eth glue driver).
>>>>>>
>>>>>> It also renames stmicro/stmmac to synopsys/ since it is a standard ethernet
>>>>>> software package regarding synopsys ethernet controllers, supporting the
>>>>>> majority of Synopsys Ethernet IPs.
>>>>>
>>>>> I understand the reason to rename stmmac driver. The only risk I see is that
>>>>> usual user will be a little bit lost to find code. It seems there no risk of
>>>>> backward compatibility with current/old DT (I assume you already checked this
>>>>> point).
>>>>
>>>> I understand your concern, but for the Synopsys IPs users will be clearer what
>>>> drivers to use and what current stmmac has to offer.
>>>
>>> I agree.
>>>
>>>>
>>>> In terms of tests, I tested it and worked out of the box because the same
>>>> Kconfig IDs were used assuring the retro-compatibility that David suggested a
>>>> few weeks ago. For DT users no problems are expected as well.
>>>
>>> Ok, sounds good.
>>>
>>> I see that you rename also Documentation/devicetree/bindings/net/stmmac.txt. You
>>> have also to change some words inside as it talks about Stmicroelectronics.
>>
>> You are right. Going to change that and send a v3. Counting on your ack :)
> 
> I continue to review ;)
> There is another point to talk. It will be strange to have the driver named
> "synopsys" but all file inside will continue to be called "stmmac" (and also
> function inside files). So either you plan to keep it as it is (and it is a
> little bit confusing) or you plan to change all file name + function name (+ few
> variable name) ?

The plan would be to change incrementally, but I have no problem in doing it all
now.

I am going to give you an example of something that must be done.

Syniopsys IP portfolium does not include a GMAC4 core, because it does not
exist. I understand why stmmac calls that way, but it is not accurate. Going to
explain why. Synopsys has the eQoS IP which version began at 4.x, and for
historical reasons drivers chose to call it gmac4 or dwmac4, when in fact it
should be named eqos or dwmac_eqos. This will have to be changed since when a
new version of eQoS is released, imagine 5.00, it will become completely
confusing. This is the reason why the files and functions named after gmac4 and
dwmac4 should be called eqos and dwmac-eqos.

We can make a total rename instead of renaming basic stuff, no problem. What do
you think?

Joao

> 
> regards
> Alex
> 
> 
> 
> 
>> Thanks!
>>
>>>
>>> Regards
>>> Alex
>>>
>>>>
>>>> Thanks,
>>>> Joao
>>>>
>>>>> Let's see what David think about that but if there no risk of backward
>>>>> compatibility with DT, I agree with the series.
>>>>>
>>>>> Regards
>>>>> Alex
>>>>>
>>>>>
>>>>>
>>>>>>
>>>>>> In the future we should make an effort to migrate to this new synopsys/
>>>>>> driver package all the Ethernet Synopsys IP drivers scattered in
>>>>>> net/ethernet.
>>>>>>
>>>>>> Joao Pinto (2):
>>>>>>   synopsys: remove dwc_eth_qos driver
>>>>>>   stmmac: rename it to synopsys
>>>>>>
>>>>>>  .../bindings/net/{stmmac.txt => synopsys.txt}      |    0
>>>>>>  MAINTAINERS                                        |   11 +-
>>>>>>  arch/arm/configs/multi_v7_defconfig                |    3 +-
>>>>>>  drivers/net/ethernet/Kconfig                       |    3 +-
>>
