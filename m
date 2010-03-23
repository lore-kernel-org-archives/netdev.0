From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC PATCH net-next 0/7 v2]IPv6:netfilter: defragment
Date: Tue, 23 Mar 2010 18:16:14 +0100
Message-ID: <4BA8F75E.2040303@trash.net>
References: <4B88BE30.80206@cn.fujitsu.com> <4B97D34C.4020509@gmail.com> <4B98B4FC.50904@cn.fujitsu.com> <4B9B9766.3090200@linux-ipv6.org> <4B9E5FEC.9010002@trash.net> <4BA8EC4A.9070802@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shan Wei <shanwei@cn.fujitsu.com>,
	YOSHIFUJI Hideaki <hideaki.yoshifuji@gmail.com>,
	David Miller <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62275 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751343Ab0CWRQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 13:16:17 -0400
In-Reply-To: <4BA8EC4A.9070802@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki wrote:
> Hello.
>
> Sorry for my slow response.
>
> (2010/03/16 1:27), Patrick McHardy wrote:
>> YOSHIFUJI Hideaki wrote:
>>> (2010/03/11 18:16), Shan Wei wrote:
>>>>> On the other hand, I'd even say we should NOT send
>>>>> icmp here (at least by default) because standard routers
>>>>> never send such packet.
>>>>
>>>> Yes=EF=BC=8Cfor routers, the patch-set does not send icmp message =
to
>>>> source host. It only does on destination host with IPv6 connection
>>>> track enable.
>>>
>>> Please make it optional (via parameter) at least.
>>
>> The ICMP messages are only sent if the packet is destined for the
>> local host, similar to what IPv6 defrag would do if conntrack wouldn=
't
>> be used. So this patch increases consistency, why should we make thi=
s
>> optional?
>
> Well, in the first place, I do think conntrack should be
> transparent as much as possible.  And, I cannot find other
> netfilter conntrack code (ipv4 or ipv6) sending icmp e.g.
> parameter problem etc.

Agreed on the transparent part, however I consider silently dropping
packets not transparent. In fact conntrack itself should never drop
packets except under some very special circumstances when there's
no other choice in order to operate correctly. Dropping packets is
supposed to be a policy decision made by the user.

In this case without conntrack, IPv6 would send an ICMPv6 message,
so in my opinion the transparent thing to do would be to still send
them. Of course only if reassembly is done on an end host.

There's really no difference in sending these packets from conntrack
compared to passing the incomplete fragments upwards to IPv6 and
waiting for another timeout, except that its easier to implement
consistently by generating the packets within conntrack.

> As I said before, I agree that netfilter may drop packets
> by any reasons, but I do think it should be done silently.
> It can increment netfilter's own statistic counting etc.
> but it should not increment the core's (especially,
> specific) statistic counting.

It really depends on what you define as "transparent".

>
> Reassembling processes are the same.  We should NOT send icmp, and
> if ever desired, we might optionally send icmp (in other
> module maybe).=20

Please see above for my reasoning. There's also the matter of consisten=
cy
between IPv4 and IPv6 conntrack.
