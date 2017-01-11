From: IgorMitsyanko <igor.mitsyanko.os@quantenna.com>
Subject: Re: [PATCH net-next] bridge: multicast to unicast
Date: Wed, 11 Jan 2017 14:26:16 +0300
Message-ID: <058f2afd-2502-e2e5-6427-1536fcd5851f@quantenna.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>, <bridge@lists.linux-foundation.org>,
        <linux-wireless@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        "David S . Miller" <davem@davemloft.net>,
        "M. Braun" <michael-dev@fami-braun.de>
To: Felix Fietkau <nbd@nbd.name>,
        Johannes Berg <johannes@sipsolutions.net>,
        =?UTF-8?Q?Linus_L=c3=bcssing?= <linus.luessing@c0d3.blue>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <73f29777-cf95-de99-f7a9-9d82e94c298d@nbd.name>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/11/2017 12:27 AM, Felix Fietkau wrote:
> On 2017-01-10 11:56, Johannes Berg wrote:
>> On Tue, 2017-01-10 at 05:18 +0100, Linus Lüssing wrote:
>>> On Mon, Jan 09, 2017 at 01:30:32PM -0800, Stephen Hemminger wrote:
>>>> I wonder if MAC80211 should be doing IGMP snooping and not bridge
>>>> in this environment.
>>>
>>> In the long term, yes. For now, not quite sure.
>>
>> There's no "for now" in the kernel. Code added now will have to be
>> maintained essentially forever.
> I'm not sure that putting the IGMP snooping code in mac80211 is a good
> idea, that would be quite a bit of code duplication.
> This implementation works, it's very simple, and it's quite flexible for
> a number of use cases.
>
> Is there any remaining objection to merging this in principle (aside
> from potential issues with the code)?
>
> - Felix
>


Hi Felix, can we consider two examples configurations with multicast 
traffic:

1. AP is a source of multicast traffic itself, no bridge on AP. For 
example, wireless video server streaming to several clients.
In this situation, we can not make use of possible advantages given by 
mc-to-uc conversion?

2. A configuration with AP + STA + 3 client devices behind STA.
                             ----|client 1|
                             |
|  mc  |----|AP|----|STA|---|---|client 2|
|server|                    |
                             ----|client 3|

Multicast server behind AP streams MC video traffic. All 3 clients 
behind the STA have joined the multicast group.
I'm not sure if this case will be handled correctly with mc-to-uc 
conversion in bridge on AP?
