From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [net-next PATCH v2 1/5] introduce IFE action
Date: Tue, 23 Feb 2016 13:31:28 -0800
Message-ID: <CAM_iQpUbWeb3-w4g8t1CgpYXqmtEBb5Tuqvz_iyATv-7g28Fog@mail.gmail.com>
References: <1456231760-2513-1-git-send-email-jhs@emojatatu.com>
	<1456231760-2513-2-git-send-email-jhs@emojatatu.com>
	<56CC5F73.9080201@iogearbox.net>
	<56CC6F3E.6000106@mojatatu.com>
	<56CC84F2.8030909@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	john fastabend <john.fastabend@gmail.com>, dj@verizon.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f176.google.com ([209.85.161.176]:35815 "EHLO
	mail-yw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754895AbcBWVb3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 16:31:29 -0500
Received: by mail-yw0-f176.google.com with SMTP id g127so158562716ywf.2
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 13:31:29 -0800 (PST)
In-Reply-To: <56CC84F2.8030909@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 23, 2016 at 8:12 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 02/23/2016 03:39 PM, Jamal Hadi Salim wrote:
>>
>> On 16-02-23 08:32 AM, Daniel Borkmann wrote:
>>>
>>> On 02/23/2016 01:49 PM, Jamal Hadi Salim wrote:
>>>>
>>>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>>>>
>>>> This action allows for a sending side to encapsulate arbitrary metadata
>>>> which is decapsulated by the receiving end.
>>>> The sender runs in encoding mode and the receiver in decode mode.
>>>> Both sender and receiver must specify the same ethertype.
>>>> At some point we hope to have a registered ethertype and we'll
>>>> then provide a default so the user doesnt have to specify it.
>>>> For now we enforce the user specify it.
>>>>
>>>> Lets show example usage where we encode icmp from a sender towards
>>>> a receiver with an skbmark of 17; both sender and receiver use
>>>> ethertype of 0xdead to interop.
>>>
>>>
>>> On a conceptual level, as this is an L2 encap with TLVs, why not having
>>> a normal device driver for this like we have in other cases that would
>>> encode/decode the meta data itself?
>>
>>
>> netdevs dont scale for large number of policies. See why ipsec which
>> at one point was implemented using a netdev and why xfrm eventually
>> was chosen as the way forward. Or look at the recent lwt
>> effort.
>
>
> Sure, I'm just saying that it could conceptionally be similar to the
> collect metadata idea just on L2 in your case. The encoding/decoding
> and transport of the information is actually not overly tc specific
> at least from the code that's shown so far, just a thought.
>

TC offers more flexibility than netdev, but on the other hand, TC
actions sit too deep in TC, you know, netdev -> qdisc -> filter -> action...
