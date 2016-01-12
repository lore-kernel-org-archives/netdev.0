From: Stas Sergeev <stsp@list.ru>
Subject: Re: Q: bad routing table cache entries
Date: Tue, 12 Jan 2016 19:42:41 +0300
Message-ID: <56952D01.6070204@list.ru>
References: <5682665A.7090102@list.ru> <56951D1D.5080602@stressinduktion.org>
 <56952147.80201@stressinduktion.org> <569523C0.5040504@list.ru>
 <56952593.8040409@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.mail.ru ([94.100.179.111]:38686 "EHLO smtp1.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752185AbcALQmr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jan 2016 11:42:47 -0500
In-Reply-To: <56952593.8040409@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

12.01.2016 19:10, Hannes Frederic Sowa =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On 12.01.2016 17:03, Stas Sergeev wrote:
>> 12.01.2016 18:52, Hannes Frederic Sowa =D0=BF=D0=B8=D1=88=D0=B5=D1=82=
:
>>> On 12.01.2016 16:34, Hannes Frederic Sowa wrote:
>>>> On 29.12.2015 11:54, Stas Sergeev wrote:
>>>>> Hello.
>>>>>
>>>>> I was hitting a strange problem when some internet hosts
>>>>> suddenly stops responding until I reboot. ping to these
>>>>> host gives "Destination Host Unreachable". After the
>>>>> initial confusion, I've finally got to
>>>>> ip route get
>>>>> and got something quite strange.
>>>>>
>>>>>
>>>>> Example for GOOD address (the one that I can ping):
>>>>>
>>>>> ip route get 91.189.89.237
>>>>> 91.189.89.237 via 192.168.8.1 dev eth0  src 192.168.10.202
>>>>>       cache
>>>>>
>>>>>
>>>>> Example for BAD address (the one that stopped responding):
>>>>>
>>>>> ip route get 91.189.89.238
>>>>> 91.189.89.238 via 192.168.0.1 dev eth0  src 192.168.10.202
>>>>>       cache <redirected>
>>>>
>>>> I tried to understand this thread and now wonder why this redirect=
 route
>>>> isn't there always. Can you please summarize again why this should=
n't
>>>> happen? It looks totally fine to me from the configuration of your
>>>> router and the subnet masks.
>>>
>>> Just an addendum:
>>>
>>> In IPv6 a redirect is seen as a notification telling hosts, this ne=
w address is on the same link as you. I think this semantic is the same=
 for IPv4, so we are informing you that in essence you are
>>> getting a /32 route installed to your new interface and can do link=
 layer resolving of the new host.
>>>
>>> I do think this is valid and fine.
>> You can't call "valid and fine" something that doesn't
>> work, at first place. Why and where does it fail, was the
>> subject of this thread.
>=20
> In terms of the shared media specification <https://tools.ietf.org/ht=
ml/rfc1620> it is valid and fine.
Good luck sending users to RFC without giving any explanations. :)
Well, yes, an interesting reading, but:
https://tools.ietf.org/html/rfc1812
---
   Routers MUST NOT generate a Redirect Message unless all the followin=
g
   conditions are met:

   o The packet is being forwarded out the same physical interface that
      it was received from,

   o The IP source address in the packet is on the same Logical IP
      (sub)network as the next-hop IP address, and

   o The packet does not contain an IP source route option.

   The source address used in the ICMP Redirect MUST belong to the same
   logical (sub)net as the destination address.
---

Could you please explain why the above does not apply?

> You can also disable shared_media on the client and it won't accept s=
uch redirects anymore.
Only "such" redirects, or any redirects?


>> If you think router did the right thing, then please explain
>> the breakage from that point of view.
> Hope it makes sense.
No, because it still doesn't work for me.
What should I do to get such redirects to work?
What should I do to at least list them?
Even if this is with accordance to some RFC (which it seems not, though=
),
this doesn't help me a tiny bit, unless it also works. :)
