From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [RFC PATCH net-next 0/7 v2]IPv6:netfilter: defragment
Date: Wed, 24 Mar 2010 03:58:58 +0900
Message-ID: <4BA90F72.6010404@linux-ipv6.org>
References: <4B88BE30.80206@cn.fujitsu.com> <4B97D34C.4020509@gmail.com> <4B98B4FC.50904@cn.fujitsu.com> <4B9B9766.3090200@linux-ipv6.org> <4B9E5FEC.9010002@trash.net> <4BA8EC4A.9070802@linux-ipv6.org> <4BA8F75E.2040303@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shan Wei <shanwei@cn.fujitsu.com>,
	YOSHIFUJI Hideaki <hideaki.yoshifuji@gmail.com>,
	David Miller <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:46360 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752844Ab0CWS71 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 14:59:27 -0400
In-Reply-To: <4BA8F75E.2040303@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

(2010/03/24 2:16), Patrick McHardy wrote:
> YOSHIFUJI Hideaki wrote:
>> Hello.
>>
>> Sorry for my slow response.
>>
>> (2010/03/16 1:27), Patrick McHardy wrote:
>>> YOSHIFUJI Hideaki wrote:
>>>> (2010/03/11 18:16), Shan Wei wrote:
>>>>>> On the other hand, I'd even say we should NOT send
>>>>>> icmp here (at least by default) because standard routers
>>>>>> never send such packet.
>>>>>
>>>>> Yes=EF=BC=8Cfor routers, the patch-set does not send icmp message=
 to
>>>>> source host. It only does on destination host with IPv6 connectio=
n
>>>>> track enable.
>>>>
>>>> Please make it optional (via parameter) at least.
>>>
>>> The ICMP messages are only sent if the packet is destined for the
>>> local host, similar to what IPv6 defrag would do if conntrack would=
n't
>>> be used. So this patch increases consistency, why should we make th=
is
>>> optional?
>>
>> Well, in the first place, I do think conntrack should be
>> transparent as much as possible.  And, I cannot find other
>> netfilter conntrack code (ipv4 or ipv6) sending icmp e.g.
>> parameter problem etc.
>
> Agreed on the transparent part, however I consider silently dropping
> packets not transparent. In fact conntrack itself should never drop
> packets except under some very special circumstances when there's
> no other choice in order to operate correctly. Dropping packets is
> supposed to be a policy decision made by the user.

Definitely right.
 =20
> In this case without conntrack, IPv6 would send an ICMPv6 message,
> so in my opinion the transparent thing to do would be to still send
> them. Of course only if reassembly is done on an end host.

Well, no.  conntrack should just forward even uncompleted fragments
to next process (e.g. core ipv6 code), and then the core would send
ICMP error back.  ICMP should be sent by the core ipv6 code according
to decision of itself, not according to netfilter.
 =20
> There's really no difference in sending these packets from conntrack
> compared to passing the incomplete fragments upwards to IPv6 and
> waiting for another timeout, except that its easier to implement
> consistently by generating the packets within conntrack.

It should never be sent by the decision of the netfilter because
the semantics and code paths are different in two cases.

>> As I said before, I agree that netfilter may drop packets
>> by any reasons, but I do think it should be done silently.
>> It can increment netfilter's own statistic counting etc.
>> but it should not increment the core's (especially,
>> specific) statistic counting.
>
> It really depends on what you define as "transparent".

I mean, netfilter conntrack should not either drop or modify any
packets, and it should not generate any additional packets.

>> Reassembling processes are the same.  We should NOT send icmp, and
>> if ever desired, we might optionally send icmp (in other
>> module maybe).
>
> Please see above for my reasoning. There's also the matter of consist=
ency
> between IPv4 and IPv6 conntrack.

Would you please explain more about what you mean by consistency
between IPv4 and IPv6 conntrack?

I do think it is rather different, anyway (because original packets
is to be preserved in IPv6, but not in IPv4).

--yoshfuji
