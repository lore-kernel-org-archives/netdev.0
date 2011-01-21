From: Hans de Bruin <jmdebruin@xmsnet.nl>
Subject: Re: [regression] 2.6.37+ commit 0363466866d9.... breaks tcp ipv6
Date: Fri, 21 Jan 2011 21:38:50 +0100
Message-ID: <4D39EEDA.90902@xmsnet.nl>
References: <4D335417.80704@xmsnet.nl>	<4D35EF64.1040906@xmsnet.nl>	 <AANLkTinejKw0pY5HncB2e0ocjqYuCwTBUwd2xkroWu+E@mail.gmail.com>	 <4D36092B.1090406@xmsnet.nl> <1295388238.8449.10.camel@edumazet-laptop>	 <4D39E2EC.9020906@xmsnet.nl> <1295639745.2609.29.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Gross <jesse@nicira.com>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail10.mail.sp.isp-net.nl ([217.149.192.62]:39328 "EHLO
	webmail10.mail.sp.isp-net.nl" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750817Ab1AUUht (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jan 2011 15:37:49 -0500
In-Reply-To: <1295639745.2609.29.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/21/2011 08:55 PM, Eric Dumazet wrote:
> Le vendredi 21 janvier 2011 =C3=A0 20:47 +0100, Hans de Bruin a =C3=A9=
crit :
>> On 01/18/2011 11:03 PM, Eric Dumazet wrote:
>>> Le mardi 18 janvier 2011 =C3=A0 22:42 +0100, Hans de Bruin a =C3=A9=
crit :
>>>> On 01/18/2011 09:06 PM, Jesse Gross wrote:
>>
>> ...
>>
>>> You could try "tcpdump -i eth0 ip6 -v"
>>>
>>> I guess you receive frames with bad checksums
>>
>> While you where staring at the code, I was fooling around with tcpdu=
mp.
>> And while the problem is fixed, I still have some questions:
>>
>> Is there tool which shows whether a nic supports ipv6 checksum offlo=
ad
>> or not?
>>
>> I have captured http traffic (wget http://bootes/) between psion (my=
 git
>> tree following laptop) and bootes (something running 2.6.33.7).
>> Attached is a capture with psion running 2.6.37 and one with this
>> morning's git tree. Wat's with the 'chsum ... ( incorrect ->  ' line=
s ?
>> ifconfig does not show errors on either of the machines.
>>
>
> tcpdump gets a copy of outgoing frames before NIC performs tx checksu=
m
> (if tx checksum handled by NIC), so it's normal to have "bad checksum=
s"
> on TX, unless you disable tx offloading (ethtool -K eth0 tx off)

That seem reasonable but: the bug was triggered because my nic could no=
t=20
offload checksumming, so what's tx=3Don if there's no support for it? I=
=20
have turned tx off and my tcpdump still shows bad checksums on outgoing=
=20
tcp/ip6 packets. I have tried 2.6.36: bad checksums, 2.6.35 and=20
surprise: good checksums with tx=3Don.

>
> I was referring to check with tcpdump incoming frames, because invali=
d
> checksums in RX is sign that other peer sent wrong checksums

Ok, thats clear, the receiving site is apparently a more reliable=20
checksummer than the sending site.

--=20
Hans
