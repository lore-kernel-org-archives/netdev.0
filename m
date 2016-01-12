From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Q: bad routing table cache entries
Date: Tue, 12 Jan 2016 18:47:19 +0100
Message-ID: <56953C27.4030405@stressinduktion.org>
References: <5682665A.7090102@list.ru> <56951D1D.5080602@stressinduktion.org>
 <56952147.80201@stressinduktion.org> <569523C0.5040504@list.ru>
 <56952593.8040409@stressinduktion.org> <56952D01.6070204@list.ru>
 <56953059.1020506@list.ru> <569532A6.1070905@stressinduktion.org>
 <56953560.9050906@list.ru> <56953740.1090204@stressinduktion.org>
 <569538FD.2060200@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: Stas Sergeev <stsp@list.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:44608 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752211AbcALRrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 12:47:21 -0500
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 7B8DD208A5
	for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 12:47:20 -0500 (EST)
In-Reply-To: <569538FD.2060200@list.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12.01.2016 18:33, Stas Sergeev wrote:
> 12.01.2016 20:26, Hannes Frederic Sowa =D0=BF=D0=B8=D1=88=D0=B5=D1=82=
:
>> On 12.01.2016 18:18, Stas Sergeev wrote:
>>> 12.01.2016 20:06, Hannes Frederic Sowa =D0=BF=D0=B8=D1=88=D0=B5=D1=82=
:
>>>> On 12.01.2016 17:56, Stas Sergeev wrote:
>>>>> 12.01.2016 19:42, Stas Sergeev =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>>>> Also the rfc1620 you pointed, seems to be saying this:
>>>>>
>>>>>                    A Redirect message SHOULD be silently discarde=
d if the
>>>>>                    new router address it specifies is not on the =
same
>>>>>                    connected (sub-) net through which the Redirec=
t arrived,
>>>>>                    or if the source of the Redirect is not the cu=
rrent
>>>>>                    first-hop router for the specified destination=
=2E
>>>>>
>>>>> It seems, this is exactly the rule we were trying to find
>>>>> during the thread. And it seems violated, either. Unless I am
>>>>> mis-interpreting it, of course.
>>>>
>>>> If you read on you will read that with shared_media this exact cla=
use (the first of those) is not in effect any more.
>>> OK. But how to get such a redirect to work, if (checked with
>>> tcpdump) the packets do not even go to eth0, but to "lo"?
>>
>> I don't know, the router must be on the same shared medium. I guess =
physical reconfiguration is required?
> It is same.
> Router 192.168.8.1 has just one ethernet port.
> And even on the 192.168.10.202 node I can do:
> # arp -a |grep "0.1"
> ? (192.168.0.1) at 14:d6:4d:1c:97:3d [ether] on eth0
> So even 0.1 is about to be reachable.
> Still nothing works.
> Should it work if 192.168.0.1 router, to which 8.1 redirects,
> has shared_media disabled?

Can you check with tcpdump? ping requires the router to also find a=20
correct way back, so packet can get stuck at a lot of places. Also uRPF=
=20
is maybe active which kind of defeats shared_media and please check=20
netfilter.

Bye,
Hannes
