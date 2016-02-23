From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next PATCH v2 1/5] introduce IFE action
Date: Tue, 23 Feb 2016 17:12:34 +0100
Message-ID: <56CC84F2.8030909@iogearbox.net>
References: <1456231760-2513-1-git-send-email-jhs@emojatatu.com> <1456231760-2513-2-git-send-email-jhs@emojatatu.com> <56CC5F73.9080201@iogearbox.net> <56CC6F3E.6000106@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	alexei.starovoitov@gmail.com, john.fastabend@gmail.com,
	dj@verizon.com
To: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38459 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753348AbcBWQMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 11:12:39 -0500
In-Reply-To: <56CC6F3E.6000106@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/23/2016 03:39 PM, Jamal Hadi Salim wrote:
> On 16-02-23 08:32 AM, Daniel Borkmann wrote:
>> On 02/23/2016 01:49 PM, Jamal Hadi Salim wrote:
>>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>>>
>>> This action allows for a sending side to encapsulate arbitrary metadata
>>> which is decapsulated by the receiving end.
>>> The sender runs in encoding mode and the receiver in decode mode.
>>> Both sender and receiver must specify the same ethertype.
>>> At some point we hope to have a registered ethertype and we'll
>>> then provide a default so the user doesnt have to specify it.
>>> For now we enforce the user specify it.
>>>
>>> Lets show example usage where we encode icmp from a sender towards
>>> a receiver with an skbmark of 17; both sender and receiver use
>>> ethertype of 0xdead to interop.
>>
>> On a conceptual level, as this is an L2 encap with TLVs, why not having
>> a normal device driver for this like we have in other cases that would
>> encode/decode the meta data itself?
>
> netdevs dont scale for large number of policies. See why ipsec which
> at one point was implemented using a netdev and why xfrm eventually
> was chosen as the way forward. Or look at the recent lwt
> effort.

Sure, I'm just saying that it could conceptionally be similar to the
collect metadata idea just on L2 in your case. The encoding/decoding
and transport of the information is actually not overly tc specific
at least from the code that's shown so far, just a thought.

> If i was to implement this as a netdev - I would have to either
> have actions to redirect to it or plumb it on top of parent
> or child devices. The main point is i am extending the tc
> graph; it doesnt make sense for me to create a device just
> for that when i could implement it as yet another action.
> And the most important reason of all: I like to implement it
> as an action;->
>
>> Why does IFE_META_MAX need to be configurable as a module parameter?
>>
>> Shouldn't the core kernel be in charge of the IFE_META_*?
>
> I struggled with that earlier.
> I cant think of a good way to limit the number of metadata
> the kernel allows for decoding without putting an upper bound.
> In order to allow people to write kernel modules without worrying
> about what is currently is hardcoded in the header file the
> only approach i could think of was to allow this number to be
> reset.

My question was rather: should the kernel enforce the IDs and only
allow what the kernel dictates (and not in/out of tree modules)? If
yes, then there would be no need for a module parameter (and the
module param should be avoided in any case).

> I have some discovery code i took out - will submit later
> which looks at these sorts of parameters.

Thanks again,
Daniel
