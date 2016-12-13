From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: Synopsys Ethernet QoS
Date: Tue, 13 Dec 2016 10:51:00 +0100
Message-ID: <49c470c8-a228-455c-f802-bc04295e5156@st.com>
References: <2df7a6dd-1128-d1d6-bf61-891f76cf7200@synopsys.com>
 <20161209.103327.1742213347114742435.davem@davemloft.net>
 <93b73b79-36aa-56b8-f975-b890b7a48bd1@synopsys.com>
 <20161209.104152.1969880574279771010.davem@davemloft.net>
 <CAHp75VcKURaTQX9=SY8+46GGATuwO1oXAi8eMS+uwk58sjKx5Q@mail.gmail.com>
 <3aee5a67-5e19-34e6-1719-ff13c7b914ea@gmail.com>
 <CAHp75VfT9B3O5jU0eHoKtgYc48K2ZjCQ-g9ZQ9nX1Hew6tz-zw@mail.gmail.com>
 <556353b7-c847-7549-626d-3c324063647e@gmail.com>
 <f5357ea2-a295-ab08-046e-f8b8f6ca4344@synopsys.com>
 <1d445ec1-deb8-6e36-39c4-6813c446095f@axis.com>
 <73bf8cb4-5685-2db6-529c-1de99b1fd358@st.com>
 <99424968-ad8f-fec6-ebcf-ab7b19ee5486@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>, <larper@axis.com>,
        <rabinv@axis.com>, netdev <netdev@vger.kernel.org>,
        <CARLOS.PALMINHA@synopsys.com>, <Jie.Deng1@synopsys.com>,
        Stephen Warren <swarren@nvidia.com>, <pavel@ucw.cz>
To: Niklas Cassel <niklas.cassel@axis.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andy Shevchenko <andy.shevchenko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:52350 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753455AbcLMJvN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2016 04:51:13 -0500
In-Reply-To: <99424968-ad8f-fec6-ebcf-ab7b19ee5486@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Niklas

On 12/13/2016 10:38 AM, Niklas Cassel wrote:
> On 12/13/2016 08:22 AM, Giuseppe CAVALLARO wrote:
>> On 12/12/2016 5:25 PM, Niklas Cassel wrote:
>>>
>>>
>>> On 12/12/2016 11:19 AM, Joao Pinto wrote:
>>>> Hi,
>>>>
>>>> Às 1:44 AM de 12/10/2016, Florian Fainelli escreveu:
>>>>> Le 12/09/16 à 16:16, Andy Shevchenko a écrit :
>>>>>> On Sat, Dec 10, 2016 at 12:52 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>>>>>>
>>>>>>> It's kind of sad that customers of that IP (stmmac, amd-xgbe, sxgbe)
>>>>>>> did
>>>>>>> actually pioneer the upstreaming effort, but it is good to see people
>>>>>>> from Synopsys willing to fix that in the future.
>>>>>> Wait, you would like to tell that we have more than 2 drivers for the
>>>>>> same (okay, same vendor) IP?!
>>>>>> It's better to unify them earlier, than have n+ copies.
>>>>> Unfortunately that is the case, see this email:
>>>>>
>>>>> https://www.mail-archive.com/netdev@vger.kernel.org/msg142796.html
>>>>>
>>>>> dwc_eth_qos and stmmac have some overlap. There seems to be work
>>>>> underway to unify these two to begin with.
>>>>>
>>>>>> P.S. Though, I don't see how sxgbe got in the list. First glance on
>>>>>> the code doesn't show similarities.
>>>>> Well samsung/sxgbe looks potentially similar to amd/xgbe, but that's
>>>>> just my cursory look at the code, it may very well be something entirely
>>>>> different. The descriptor formats just look suspiciously similar.
>>>>>
>>>> Thank you for your inputs! Renaming seems to be a hotspot. I agree that maybe
>>>> instead of renaming (breaking retro-compatibility as David and Florian
>>>> mentioned), the best is to move stmmac to synopsys/ after merging *qos* and
>>>> removing it. As Florian mentioned, git is capable of detecting folder restructured.
>>>>
>>>> @Rabin Vincent: Hi Rabin. Since Axis is more familiar with the synopsys/*qos*
>>>> driver would it be possible for you to make an initial analysis of what has to
>>>> be merged into Stmmac? This way the development would speed-up.
>>>
>>> I can answer that question.
>>>
>>> I've sent out 12 patches to the stmmac driver
>>> (all patches are included in the current net-next tree),
>>
>> ok I have seen these patches applied, I had just a minor concern about
>> the  failure when DMA configuration is missing.
>> In these years, I have noticed that, for this kind of HW, default DMA
>> configuration is usually good to have a driver working. AHB, AXI
>> parameters can be provided to have a best tuning or to fix know issues
>> on some platforms. So IMO, we should relax the check with a warning.
>> Please, consider that, the stmmac also supports very old MAC10/100
>> versions where the DMA configuration was often never passed.
>>
>
> This might be a bit off-topic, but:

yes indeed ;-)

> The patch should not affect any existing code.
> All glue drivers uses stmmac_probe_config_dt,
> which sets a default value if the property is missing or zero.
> The PCI glue driver sets the property explicitly.
> Hence, all current code should not be affected.
> The error check was added as a sanity check, just in case some
> new code is added, which bypasses stmmac_probe_config_dt,
> lets say support for GMAC4 in the PCI glue driver.
>

ok

>>
>>>
>>> There are some performance problems with the stmmac driver though:
>>>
>>> When running iperf3 with 3 streams:
>>> iperf3 -c 192.168.0.90 -P 3 -t 30
>>> iperf3 -c 192.168.0.90 -P 3 -t 30 -R
>>>
>>> I get really bad fairness between the streams.
>>
>> Can you confirm you are using the 4.xxa version?
>
> Yes, 4.10a.
> Reading the MAC_Version register gives:
> 0x00004041
> Where SNPSVER is bit 7:0, so 0x41.

ok

>
>
>>
>> This doesn't match with Alex's experiments on ARM platforms.
>>
>
> We are also using an ARM platform.
> There is no problem with throughput.

ok

> The problem is fairness between the streams,
> when using for example 3 streams in iperf3.

hmm I let Alex to reply.

AFAIK, other people played with stream tests and
no issue but, if you get problems so we have to
investigate.

> Did Alex test this? I could not find Alex mail in the netdev archives,
> could you link to it?
> The problem goes away when disabling TX IRQ coalescing,
> which I guess makes sense, since like David Miller said:
>
> "the driver is using non-highres timers
> to implement the TX coalescing.  [...]
> 1 HZ, which is the lowest granularity of non-highres timers in the
> kernel, is variable as well as already too large of a delay for
> effective TX coalescing."
>
> We are using CONFIG_HZ=100, not CONFIG_HZ=1000.

1000 was a default on our platforms

>
> So if there is a long time before handling interrupts,
> I guess that it makes sense that one stream could
> get an advantage in the net scheduler.

ok

>
> If I find the time, and if no one beats me to it, I will try to replace
> the normal timers with HR timers + a smaller default timeout.

that's great.

>>
>>> We have a local patch that implements TX IRQ coalescing in the dwceqos driver,
>>> and we don't see the same problem.
>>
>> please, if you have new patch add me on CC and we will review all
>> together.
>
> I think you misunderstood me, we have a local patch for the synopsys/dwc_eth_qos.c
> version, not for stmmac.

oops, sorry

>
> I have been using get_maintainer.pl, so you should have been added to all my patches,
> but if I send any further patches, I will make sure that you are not excluded.

thanks a lot

Regards
Peppe

>
>
