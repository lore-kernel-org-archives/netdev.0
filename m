From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: RFC: netfilter: synproxy iptables target
Date: Thu, 20 May 2010 22:21:58 +0800
Message-ID: <AANLkTimjY_0yKfMtAUxI7He-QH5R5AdDCR3V8eKSgbGq@mail.gmail.com>
References: <AANLkTimp6S7MpwDAT8l-M0ZWjs2HIcUEfL5f8j9-QDZh@mail.gmail.com>
	<4BF54310.6030004@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:58542 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754376Ab0ETOWT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 10:22:19 -0400
In-Reply-To: <4BF54310.6030004@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 20, 2010 at 10:11 PM, Patrick McHardy <kaber@trash.net> wro=
te:
> Changli Gao wrote:
>> I have implemented a simple SYNPROXY iptables target. It is much lik=
e
>> the SYNPROXY implementation in pf of OpenBSD, but won't have state
>> until the first connection is established with the help of syncookie=
s.
>> The code is hosted at github:
>>
>> http://github.com/xiaosuo/xiaosuo/tree/master/synproxy/
>>
>> Currently, it can work with firewall and local socket.
>>
>> It is in the very early stage, and ugly. And I will add --timeout
>> parameter to this target as TCP_DFER_ACCEPT, so I can do NAT basing =
on
>> the request data.
>>
>> i.e.
>>
>> iptables -t nat -A OUTPUT -p tcp -m synproxy --http-url "*.jpg" -j
>> DNAT --to-destination $image_http_server:80
>>
>> And is there any chance to merge it into mainline?
>
> If you can state a good use case, sure. I don't know much about the
> PF synproxy myself.
>

pure synproxy can be used on firewall to protect the internal servers,
which don't support neither syncookies and synproxy, from the attack
of SYN-flood.

synproxy with defered connection relay acts as a layer 7 proxy, but
works in kernel space totally, unlike tcp splice tech., which needs
the applications in user space parse the requests, and establish the
connections.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
