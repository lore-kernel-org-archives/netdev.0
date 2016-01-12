From: Stas Sergeev <stsp@list.ru>
Subject: Re: Q: bad routing table cache entries
Date: Tue, 12 Jan 2016 18:57:42 +0300
Message-ID: <56952276.8050207@list.ru>
References: <5682665A.7090102@list.ru> <56951D1D.5080602@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp35.i.mail.ru ([94.100.177.95]:56314 "EHLO smtp35.i.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752764AbcALP5u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jan 2016 10:57:50 -0500
In-Reply-To: <56951D1D.5080602@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

12.01.2016 18:34, Hannes Frederic Sowa =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On 29.12.2015 11:54, Stas Sergeev wrote:
>> Hello.
>>
>> I was hitting a strange problem when some internet hosts
>> suddenly stops responding until I reboot. ping to these
>> host gives "Destination Host Unreachable". After the
>> initial confusion, I've finally got to
>> ip route get
>> and got something quite strange.
>>
>>
>> Example for GOOD address (the one that I can ping):
>>
>> ip route get 91.189.89.237
>> 91.189.89.237 via 192.168.8.1 dev eth0  src 192.168.10.202
>>      cache
>>
>>
>> Example for BAD address (the one that stopped responding):
>>
>> ip route get 91.189.89.238
>> 91.189.89.238 via 192.168.0.1 dev eth0  src 192.168.10.202
>>      cache <redirected>
>=20
> I tried to understand this thread and now wonder why this redirect ro=
ute isn't there always. Can you please summarize again why this shouldn=
't happen? It looks totally fine to me from the
> configuration of your router and the subnet masks.
http://www.spinics.net/lists/netdev/msg358200.html
Sowmini Varadhan explains:
---
According to rfc1812 (pg 82-84)

   Routers MUST NOT generate a Redirect Message unless all the followin=
g
   conditions are met:

   o The packet is being forwarded out the same physical interface that
      it was received from,

   o The IP source address in the packet is on the same Logical IP
      (sub)network as the next-hop IP address, and

   o The packet does not contain an IP source route option.

The second condition seems to have been violated by the router.
---

And he also shows the tunable that stops the router from violating this=
=2E
Good that linux can be at least tuned to do the right thing. :)

The fewer explained question is why the bad route is ever accepted.
This is what actually looks risky.
