From: Stas Sergeev <stsp@list.ru>
Subject: Re: Q: bad routing table cache entries
Date: Tue, 12 Jan 2016 19:56:57 +0300
Message-ID: <56953059.1020506@list.ru>
References: <5682665A.7090102@list.ru> <56951D1D.5080602@stressinduktion.org>
 <56952147.80201@stressinduktion.org> <569523C0.5040504@list.ru>
 <56952593.8040409@stressinduktion.org> <56952D01.6070204@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp20.mail.ru ([94.100.179.251]:43180 "EHLO smtp20.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965154AbcALQ5E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jan 2016 11:57:04 -0500
In-Reply-To: <56952D01.6070204@list.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

12.01.2016 19:42, Stas Sergeev =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> 12.01.2016 19:10, Hannes Frederic Sowa =D0=BF=D0=B8=D1=88=D0=B5=D1=82=
:
>> On 12.01.2016 17:03, Stas Sergeev wrote:
>>> 12.01.2016 18:52, Hannes Frederic Sowa =D0=BF=D0=B8=D1=88=D0=B5=D1=82=
:
>>>> On 12.01.2016 16:34, Hannes Frederic Sowa wrote:
>>>>> On 29.12.2015 11:54, Stas Sergeev wrote:
>>>>>> Hello.
>>>>>>
>>>>>> I was hitting a strange problem when some internet hosts
>>>>>> suddenly stops responding until I reboot. ping to these
>>>>>> host gives "Destination Host Unreachable". After the
>>>>>> initial confusion, I've finally got to
>>>>>> ip route get
>>>>>> and got something quite strange.
>>>>>>
>>>>>>
>>>>>> Example for GOOD address (the one that I can ping):
>>>>>>
>>>>>> ip route get 91.189.89.237
>>>>>> 91.189.89.237 via 192.168.8.1 dev eth0  src 192.168.10.202
>>>>>>       cache
>>>>>>
>>>>>>
>>>>>> Example for BAD address (the one that stopped responding):
>>>>>>
>>>>>> ip route get 91.189.89.238
>>>>>> 91.189.89.238 via 192.168.0.1 dev eth0  src 192.168.10.202
>>>>>>       cache <redirected>
>>>>>
>>>>> I tried to understand this thread and now wonder why this redirec=
t route
>>>>> isn't there always. Can you please summarize again why this shoul=
dn't
>>>>> happen? It looks totally fine to me from the configuration of you=
r
>>>>> router and the subnet masks.
>>>>
>>>> Just an addendum:
>>>>
>>>> In IPv6 a redirect is seen as a notification telling hosts, this n=
ew address is on the same link as you. I think this semantic is the sam=
e for IPv4, so we are informing you that in essence you are
>>>> getting a /32 route installed to your new interface and can do lin=
k layer resolving of the new host.
>>>>
>>>> I do think this is valid and fine.
>>> You can't call "valid and fine" something that doesn't
>>> work, at first place. Why and where does it fail, was the
>>> subject of this thread.
>>
>> In terms of the shared media specification <https://tools.ietf.org/h=
tml/rfc1620> it is valid and fine.
> Good luck sending users to RFC without giving any explanations. :)
> Well, yes, an interesting reading, but:
> https://tools.ietf.org/html/rfc1812
> ---
>    Routers MUST NOT generate a Redirect Message unless all the follow=
ing
>    conditions are met:
>=20
>    o The packet is being forwarded out the same physical interface th=
at
>       it was received from,
>=20
>    o The IP source address in the packet is on the same Logical IP
>       (sub)network as the next-hop IP address, and
>=20
>    o The packet does not contain an IP source route option.
>=20
>    The source address used in the ICMP Redirect MUST belong to the sa=
me
>    logical (sub)net as the destination address.
> ---
>=20
> Could you please explain why the above does not apply?
Also the rfc1620 you pointed, seems to be saying this:

                A Redirect message SHOULD be silently discarded if the
                new router address it specifies is not on the same
                connected (sub-) net through which the Redirect arrived=
,
                or if the source of the Redirect is not the current
                first-hop router for the specified destination.

It seems, this is exactly the rule we were trying to find
during the thread. And it seems violated, either. Unless I am
mis-interpreting it, of course.
