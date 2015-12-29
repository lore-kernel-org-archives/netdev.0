From: Stas Sergeev <stsp@list.ru>
Subject: Re: Q: bad routing table cache entries
Date: Tue, 29 Dec 2015 15:06:49 +0300
Message-ID: <56827759.8020605@list.ru>
References: <5682665A.7090102@list.ru> <20151229115821.GA9352@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp51.i.mail.ru ([94.100.177.111]:55765 "EHLO smtp51.i.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751538AbbL2MG5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Dec 2015 07:06:57 -0500
In-Reply-To: <20151229115821.GA9352@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

29.12.2015 14:58, Sowmini Varadhan =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On (12/29/15 13:54), Stas Sergeev wrote:
>>
>> ip route get 91.189.89.238
>> 91.189.89.238 via 192.168.0.1 dev eth0  src 192.168.10.202
>>     cache <redirected>
>          :
>> Now, 192.168.0.1 is also a valid gateway, but it is outside
>> of the network mask for the eth0 interface:
>          :
>> So my question is: why does linux allow an invalid redirect
>> entries? Is it a problem with my setup, or some kernel bug,
>> or some router setup problem? Where should I look into, to
>> nail this down?
>=20
> Seems like the problem is in the router that is sending
> the bad redirect. You would have to check into the configuration
> and/or implementation of the router- it should not be sending
> back a redirect in the above case (different netmasks) even
> if the ingress and egress physical interfaces are the same.
Router on 192.168.8.1 is just a PC with ubuntu, w/o any special
software. I'd be very surprised if it does so. As I understand,
linux would accept such ICMP redirect only from the router, or
could someone else also send them?

But what worries me more, is the question:
Should the linux kernel really silently accept those, breaking
the routing in a completely unexpected ways? Isn't it a bug?
The sanity check against netmask looks trivial, so why it is not there?
