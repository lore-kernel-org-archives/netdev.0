From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Q: bad routing table cache entries
Date: Tue, 12 Jan 2016 17:10:59 +0100
Message-ID: <56952593.8040409@stressinduktion.org>
References: <5682665A.7090102@list.ru> <56951D1D.5080602@stressinduktion.org>
 <56952147.80201@stressinduktion.org> <569523C0.5040504@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Stas Sergeev <stsp@list.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:37389 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753295AbcALQLB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 11:11:01 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id E6846209F7
	for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 11:11:00 -0500 (EST)
In-Reply-To: <569523C0.5040504@list.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12.01.2016 17:03, Stas Sergeev wrote:
> 12.01.2016 18:52, Hannes Frederic Sowa =D0=BF=D0=B8=D1=88=D0=B5=D1=82=
:
>> On 12.01.2016 16:34, Hannes Frederic Sowa wrote:
>>> On 29.12.2015 11:54, Stas Sergeev wrote:
>>>> Hello.
>>>>
>>>> I was hitting a strange problem when some internet hosts
>>>> suddenly stops responding until I reboot. ping to these
>>>> host gives "Destination Host Unreachable". After the
>>>> initial confusion, I've finally got to
>>>> ip route get
>>>> and got something quite strange.
>>>>
>>>>
>>>> Example for GOOD address (the one that I can ping):
>>>>
>>>> ip route get 91.189.89.237
>>>> 91.189.89.237 via 192.168.8.1 dev eth0  src 192.168.10.202
>>>>       cache
>>>>
>>>>
>>>> Example for BAD address (the one that stopped responding):
>>>>
>>>> ip route get 91.189.89.238
>>>> 91.189.89.238 via 192.168.0.1 dev eth0  src 192.168.10.202
>>>>       cache <redirected>
>>>
>>> I tried to understand this thread and now wonder why this redirect =
route
>>> isn't there always. Can you please summarize again why this shouldn=
't
>>> happen? It looks totally fine to me from the configuration of your
>>> router and the subnet masks.
>>
>> Just an addendum:
>>
>> In IPv6 a redirect is seen as a notification telling hosts, this new=
 address is on the same link as you. I think this semantic is the same =
for IPv4, so we are informing you that in essence you are
>> getting a /32 route installed to your new interface and can do link =
layer resolving of the new host.
>>
>> I do think this is valid and fine.
> You can't call "valid and fine" something that doesn't
> work, at first place. Why and where does it fail, was the
> subject of this thread.

In terms of the shared media specification=20
<https://tools.ietf.org/html/rfc1620> it is valid and fine.

You can also disable shared_media on the client and it won't accept suc=
h=20
redirects anymore. It is just what we defined as the default.

> If you think router did the right thing, then please explain
> the breakage from that point of view.

Hope it makes sense.

Bye,
Hannes
