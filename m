From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH net-next 2/2] udp: add sk opt to allow sending pkt
 with src 0.0.0.0
Date: Thu, 14 Nov 2013 14:05:00 +0100
Message-ID: <5284CA7C.7030402@6wind.com>
References: <20131105205744.GK8832@order.stressinduktion.org>	<1383958474-6255-1-git-send-email-nicolas.dichtel@6wind.com>	<1383958474-6255-2-git-send-email-nicolas.dichtel@6wind.com> <20131111.001803.110603937316567461.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
	David.Laight@ACULAB.COM, jiri@resnulli.us, vyasevich@gmail.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, thaller@redhat.com, stephen@networkplumber.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:45718 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753361Ab3KNNFD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 08:05:03 -0500
Received: by mail-wg0-f50.google.com with SMTP id k14so1905145wgh.29
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 05:05:02 -0800 (PST)
In-Reply-To: <20131111.001803.110603937316567461.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 11/11/2013 06:18, David Miller a =E9crit :
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Sat,  9 Nov 2013 01:54:34 +0100
>
>> This feature allows to a send packets with address source set to 0.0=
=2E0.0 even if
>> an ip address is available on another interface.
>>
>> It's useful for DHCP client, to allow them to use UDP sockets and be=
 compliant
>> with the RFC2131, Section 4.1:
>>
>> 4.1 Constructing and sending DHCP messages
>> ...
>>     DHCP messages broadcast by a client prior to that client obtaini=
ng
>>     its IP address must have the source address field in the IP head=
er
>>     set to 0.
>>
>> Based on a previous work from
>> Guillaume Gaudonville <guillaume.gaudonville@6wind.com>.
>>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>
> This requirement of the RFC is inconsistent with a host based
> addressing model, that which Linux employs, it assumes an interface
> based one.
There are some exceptions, for example when user tunes arp_ignore sysct=
l ;-)

>
> The wording here is also very ambiguous.
>
> This RFC fails to even remotely consider what the right behavior
> should be in a host based addressing environment at all, and anyone
> reading this RFC should just accept that.
I agree that this is ambiguous. And it's a 'must', not a 'MUST', which
is not the same for an RFC ;-)

>
> Furthermore, the fact that you're implementing _addressing_ policy in
> the UDP code makes this change even more unreasonable.
>
I made this choice because using 0.0.0.0, for TCP for example, seems a
non-sense.

But fair enough, let's drop this patch.


Thank you,
Nicolas
