From: Felix Fietkau <nbd@nbd.name>
Subject: Re: [PATCH net-next] bridge: multicast to unicast
Date: Wed, 11 Jan 2017 13:21:34 +0100
Message-ID: <8d3f0bd9-8b66-ce49-ab1d-56e8c73764fc@nbd.name>
References: <20170102193214.31723-1-linus.luessing@c0d3.blue>
 <1483706872.4089.8.camel@sipsolutions.net>
 <8836daaa-9638-4502-d079-fd428595f822@nbd.name>
 <1483710841.12677.1.camel@sipsolutions.net>
 <22fad045-57c6-7789-d19f-f47bd0faf441@fami-braun.de>
 <20170107145516.GE3134@otheros> <1483949336.17582.3.camel@sipsolutions.net>
 <6f5ec9f1-800a-2bc4-2f41-9d803343bb22@fami-braun.de>
 <20170109212345.GA5513@otheros> <20170109133032.221f8669@xeon-e3>
 <20170110041816.GJ5513@otheros> <1484045763.1014.0.camel@sipsolutions.net>
 <73f29777-cf95-de99-f7a9-9d82e94c298d@nbd.name>
 <058f2afd-2502-e2e5-6427-1536fcd5851f@quantenna.com>
 <015bf651-7584-13c0-16b9-d4e29e23c96b@nbd.name>
 <ee946686-699c-da64-4932-f58e3f1a83ad@quantenna.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
        linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
        "David S . Miller" <davem@davemloft.net>,
        "M. Braun" <michael-dev@fami-braun.de>
To: IgorMitsyanko <igor.mitsyanko.os@quantenna.com>,
        Johannes Berg <johannes@sipsolutions.net>,
        =?UTF-8?Q?Linus_L=c3=bcssing?= <linus.luessing@c0d3.blue>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ee946686-699c-da64-4932-f58e3f1a83ad@quantenna.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2017-01-11 13:15, IgorMitsyanko wrote:
> On 01/11/2017 02:30 PM, Felix Fietkau wrote:
>> On 2017-01-11 12:26, IgorMitsyanko wrote:
>>> On 01/11/2017 12:27 AM, Felix Fietkau wrote:
>>>> On 2017-01-10 11:56, Johannes Berg wrote:
>>>>> On Tue, 2017-01-10 at 05:18 +0100, Linus Lüssing wrote:
>>>>>> On Mon, Jan 09, 2017 at 01:30:32PM -0800, Stephen Hemminger wrote:
>>>>>>> I wonder if MAC80211 should be doing IGMP snooping and not bridge
>>>>>>> in this environment.
>>>>>> In the long term, yes. For now, not quite sure.
>>>>> There's no "for now" in the kernel. Code added now will have to be
>>>>> maintained essentially forever.
>>>> I'm not sure that putting the IGMP snooping code in mac80211 is a good
>>>> idea, that would be quite a bit of code duplication.
>>>> This implementation works, it's very simple, and it's quite flexible for
>>>> a number of use cases.
>>>>
>>>> Is there any remaining objection to merging this in principle (aside
>>>> from potential issues with the code)?
>>>>
>>>> - Felix
>>>>
>>>
>>> Hi Felix, can we consider two examples configurations with multicast
>>> traffic:
>>>
>>> 1. AP is a source of multicast traffic itself, no bridge on AP. For
>>> example, wireless video server streaming to several clients.
>>> In this situation, we can not make use of possible advantages given by
>>> mc-to-uc conversion?
>> You could simply put the AP interface in a bridge, no need to have any
>> other bridge members present.
>>
>>> 2. A configuration with AP + STA + 3 client devices behind STA.
>>>                               ----|client 1|
>>>                              |
>>> |  mc  |----|AP|----|STA|---|---|client 2|
>>> |server|                    |
>>>                               ----|client 3|
>>>
>>> Multicast server behind AP streams MC video traffic. All 3 clients
>>> behind the STA have joined the multicast group.
>>> I'm not sure if this case will be handled correctly with mc-to-uc
>>> conversion in bridge on AP?
>> What do you mean by "3 client devices behind STA"? Are you using a
>> 4-addr STA, multicast routing, or some kind of vendor specific "client
>> bridge" hackery?
> 
> 3 client devices connected by backbone Ethernet network. Generic
> case is probably STA/AP operating in 4-addr mode (more or less standard
> solution as far as I know).
If the AP is running in 4-addr mode, it will need to have a bridge
interface anyway, because the link to the STA will be split out into a
separate virtual interface (AP_VLAN iftype).

In this case you don't actually need any multicast-to-unicast
conversion, because the multicast traffic will be unicast on 802.11
already (due to use of 4-addr mode).

- Felix
