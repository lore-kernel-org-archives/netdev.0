From: Niklas Cassel <niklas.cassel@axis.com>
Subject: Re: Synopsys Ethernet QoS
Date: Mon, 19 Dec 2016 17:05:23 +0100
Message-ID: <b99adc2a-38e2-9a22-479b-44d407a9cb6c@axis.com>
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
 <9bedb947-e27b-6bd8-ec11-6389afd189ec@synopsys.com>
 <b6cbe6e6-c998-302a-36d3-2183acb076d9@axis.com>
 <46E178AA-6100-4244-BB8D-B5EA58E96E72@axis.com>
 <c6eb5745-20b3-daac-33b4-b20c568344b8@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Andy Shevchenko <andy.shevchenko@gmail.com>,
        David Miller <davem@davemloft.net>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        Rabin Vincent <rabinv@axis.com>,
        netdev <netdev@vger.kernel.org>,
        "CARLOS.PALMINHA@synopsys.com" <CARLOS.PALMINHA@synopsys.com>,
        "Jie.Deng1@synopsys.com" <Jie.Deng1@synopsys.com>,
        Stephen Warren <swarren@nvidia.com>,
        "pavel@ucw.cz" <pavel@ucw.cz>
To: Joao Pinto <Joao.Pinto@synopsys.com>,
        Lars Persson <larper@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bes.se.axis.com ([195.60.68.10]:59623 "EHLO bes.se.axis.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754668AbcLSQGY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Dec 2016 11:06:24 -0500
In-Reply-To: <c6eb5745-20b3-daac-33b4-b20c568344b8@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/13/2016 01:56 PM, Joao Pinto wrote:
> Às 12:50 PM de 12/13/2016, Lars Persson escreveu:
>>> 13 dec. 2016 kl. 13:31 skrev Niklas Cassel <Niklas.Cassel@axis.com>:
>>>
>>>
>>>
>>>> On 12/13/2016 12:49 PM, Joao Pinto wrote:
>>>> Hi Niklas,
>>>>
>>>> Às 4:25 PM de 12/12/2016, Niklas Cassel escreveu:
>>>>>> On 12/12/2016 11:19 AM, Joao Pinto wrote:
>>>>>> Hi,
>>>>>>
>>>>>> Às 1:44 AM de 12/10/2016, Florian Fainelli escreveu:
>>>>>>>> Le 12/09/16 à 16:16, Andy Shevchenko a écrit :
>>>>>>>> On Sat, Dec 10, 2016 at 12:52 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>>>> (snip...)
>>>>
>>>>
>>>>>> @Rabin Vincent: Hi Rabin. Since Axis is more familiar with the synopsys/*qos*
>>>>>> driver would it be possible for you to make an initial analysis of what has to
>>>>>> be merged into Stmmac? This way the development would speed-up.
>>>>> I can answer that question.
>>>>>
>>>>> I've sent out 12 patches to the stmmac driver
>>>>> (all patches are included in the current net-next tree),
>>>>> with these patches the stmmac driver works properly on Axis hardware
>>>>> (we use Synopsys GMAC 4.10a synthesized with multiple TX queues).
>>>>> stmmac's DT binding has also been extended with properties that
>>>>> existed in DWC EQoS's DT binding, such as no-pbl-x8, txpbl, rxpbl.
>>>>>
>>>>> Since we have no problem updating the DTB together with the kernel,
>>>>> we will simply move to using the start using the stmmac driver,
>>>>> with stmmac's DT binding.
>>>>>
>>>>> However, I've noticed that NVIDIA has extended the DWC EQoS DT binding,
>>>>> I don't how easy it would be for them to switch to stmmac's DT binding.
>>>>> (Adding Stephen Warren to CC.)
>>>>>
>>>>> The reset sequence that Lars Persson was worried about is not an issue
>>>>> with the stmmac driver.
>>>> Great! So you saying that stmmac works great with AXIS hardware and no need to
>>>> merge specific code from AXIS' *qos* driver?
>>> Yes. From Axis point of view, we are done.
>>> stmmac works and we will move to that driver + DT binding.
>>>
>>> However, it seems like Stephen Warren will NAK if you try to remove
>>> synopsys/dwc_eth_qos.c before
>>> Documentation/devicetree/bindings/net/stmmac.txt
>>> is compatible with
>>> Documentation/devicetree/bindings/net/snps,dwc-qos-ethernet.txt
>>>
>>> You might want to sync with him. I have no idea, but perhaps they are
>>> only using a subset of all the available properties. Perhaps,
>>> only implementing what they are using might be enough, I don't know.
>>> I couldn't find their DTS in arch/arm/dts.
>>> I guess you might want to know David Miller's opinion,
>>> since he's the one who decides in the end.
>> I will also NACK removal of dwc_eth_qos.c until the binding is implemented elsewhere.
> Totally agree.
> @Niklas: David Miller is informed of what we are planning to do. Can you
> estimate the effort of merging the axis driver device tree bindings? If there
> was anyone from axis to do the merge would be better since you are familiar with
> it. What do you think?

Since stmmac supports glue layers, the best thing is probably
to create a new glue layer
(see for example drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c
with matching Documentation/devicetree/bindings/net/meson-dwmac.txt).

That way we don't have to "contaminate" the generic code in
stmmac_platform.c and dwmac-generic.c.

The only code needed in the glue driver would be the code to parse the
devicetree properties specific to dwc_eth_qos.c.
Hence, the amount of code you will have to write will be very limited.
Writing the code will probably be quick, but since you will have to
fix review comments etc., I would estimate it to be around 1-2 days work.

Since we have already moved to stmmac's DT binding,
we don't really care about the old binding, but I will gladly
help you by performing code reviews if you would like.


>
>>
>>>>>
>>>>>
>>>>> There are some performance problems with the stmmac driver though:
>>>>>
>>>>> When running iperf3 with 3 streams:
>>>>> iperf3 -c 192.168.0.90 -P 3 -t 30
>>>>> iperf3 -c 192.168.0.90 -P 3 -t 30 -R
>>>>>
>>>>> I get really bad fairness between the streams.
>>>>>
>>>>> This appears to be an issue with how TX IRQ coalescing is implemented in stmmac.
>>>>> Disabling TX IRQ coalescing in the stmmac driver makes the problem go away.
>>>>> We have a local patch that implements TX IRQ coalescing in the dwceqos driver,
>>>>> and we don't see the same problem.
>>>>>
>>>>> Also netperf TCP_RR and UDP_RR gives really bad results compared to the
>>>>> dwceqos driver (without IRQ coalescing).
>>>>> 2000 transactions/sec vs 9000 transactions/sec.
>>>>> Turning TX IRQ coalescing off and RX interrupt watchdog off in stmmac
>>>>> gives the same performance. I guess it's a trade off, low CPU usage
>>>>> vs low latency, so I don't know how important TCP_RR/UDP_RR really is.
>>>>>
>>>>> The best thing would be to get a good working TX IRQ coalesce
>>>>> implementation with HR timers in stmmac.
>>>>> Perhaps it should also be investigated if the RX interrupt watchdog
>>>>> timeout should have a lower default value.
>>>>>
>>>>>
>>>>>
>>>>>> Thanks to all.
>>>>>>
>>>>>> Joao
