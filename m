From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next PATCH 0/5] net_sched: Add support for IFE action
Date: Fri, 26 Feb 2016 01:03:42 +0100
Message-ID: <56CF965E.8000103@iogearbox.net>
References: <1456147304-13355-1-git-send-email-jhs@emojatatu.com> <56CB3B90.8030206@iogearbox.net> <56CC4BEA.70108@mojatatu.com> <56CC5CB6.1030807@iogearbox.net> <56CC6C75.1000903@mojatatu.com> <56CC7C20.3090302@iogearbox.net> <56CDA6E8.7010604@mojatatu.com> <56CDECE5.5040604@iogearbox.net> <56CEF242.5090908@mojatatu.com> <56CF7370.7020100@iogearbox.net> <56CF82ED.3080307@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	alexei.starovoitov@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40663 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751544AbcBZADu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 19:03:50 -0500
In-Reply-To: <56CF82ED.3080307@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/25/2016 11:40 PM, Jamal Hadi Salim wrote:
> On 16-02-25 04:34 PM, Daniel Borkmann wrote:
>> On 02/25/2016 01:23 PM, Jamal Hadi Salim wrote:
>>> On 16-02-24 12:48 PM, Daniel Borkmann wrote:
>>>> On 02/24/2016 01:49 PM, Jamal Hadi Salim wrote:
>> [...]
>>>>> Drivers do set the hash. My use case is slightly different.
>>>>> I have a NIC which has an embedded cavium processor. This thing
>>>>> strips off the TLV and uses the hash to select the host MSI.
>>>>> Only thing we dont use at the moment is queue_mapping.
>>>>
>>>> Ok, but the example says ingress qdisc. ;) I presume the driver for the
>>>> NIC and the offloading parts are non-public? :/
>>>
>>> Well, it is not exactly mellanox or intel - but I am sure someone would
>>> be willing to sell that NIC.
>>>
>>>> So, without them, placing
>>>> this on ingress qdisc doesn't seem much useful wrt the skb hash example,
>>>> and most people only have the software part (for ingress I mean)
>>>> available.
>>>
>>> Do you want me to take skbbhash out? I just want to get this set in then
>>> worry about adding and modifying.
>>
>> Well, if the NIC driver and offloading parts for ife are not available
>> (or cannot be made available)
>
> If you are willing to pay for one i can have one sold to you.
> Note: There is no dependency on such a NIC. You asked for an example
> of how one would use skbhash and i pointed it out to you.
> Infact nothing in the commit notes pointed to any NIC.

Yes, but that was not the point, I think we're talking past each other. ;)
The example (or better, use-case) you provided with your NIC seems useful.
But when you want to decode this with your kernel module, f.e. attached on
ingress qdisc, it's an entirely different situation. Anyway, point is subsequent
calls to skb_get_hash() will overwrite what you decoded there, that's why I
asked and tried to point this out earlier. You may want to look at sth
like __skb_set_sw_hash() ...

>> in the upstream kernel tree, then you have
>> to assume that everyone else can _only_ use this with the existing tc
>> facilities in the kernel. And as such, the whole set needs to be evaluated,
>> I think this is nothing new. ;-)
>
> Seriously this is getting to a ridiculous level now.
> I gave a talk - which you attended. I wrote a paper which you may have
> at minimal glanced at.
> I have had discussions with you on this very subject.

I think I only suggested that in case you still don't have an ethertype
assigned to this to require the user to specify one instead of some default.

> And as soon as i posted the patches your statements led from you
> needing a good use case to why not use a netdev and why i have
> all these things that are not very useful. None of which came up before.

Fair enough, didn't see that code before and just tried to review it, probably
shouldn't have, so I'm not looking further into this anymore. ;)

Thanks anyway,
Daniel
