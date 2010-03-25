From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [RFC PATCH net-next 0/7 v2]IPv6:netfilter: defragment
Date: Thu, 25 Mar 2010 23:14:57 +0900
Message-ID: <4BAB6FE1.7030304@linux-ipv6.org>
References: <4B88BE30.80206@cn.fujitsu.com> <4B97D34C.4020509@gmail.com> <4B98B4FC.50904@cn.fujitsu.com> <4B9B9766.3090200@linux-ipv6.org> <4B9E5FEC.9010002@trash.net> <4BA8EC4A.9070802@linux-ipv6.org> <4BA8F75E.2040303@trash.net> <4BA90F72.6010404@linux-ipv6.org> <alpine.DEB.2.00.1003232050540.18241@blackhole.kfki.hu> <4BAAE496.8000701@linux-ipv6.org> <alpine.DEB.2.00.1003251004200.21825@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Shan Wei <shanwei@cn.fujitsu.com>,
	YOSHIFUJI Hideaki <hideaki.yoshifuji@gmail.com>,
	David Miller <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:42096 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754485Ab0CYOPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 10:15:39 -0400
In-Reply-To: <alpine.DEB.2.00.1003251004200.21825@blackhole.kfki.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2010/03/25 18:23), Jozsef Kadlecsik wrote:

>> First of all. in "sane" setup, people should configure according
>> to their own requirements.  They may or may not want send back
>> icmp packet.  And, even if the core is to send icmp back, the
>> state would be correctly assigned.
>
> I meant the state of the fragmented packets. If we let the uncompleted
> fragments to enter conntrack, as far as I see their state will be INVALID.
> Or should we add an exception and set their state to UNTRACKED in
> conntrack?

Got it.  INVALID seems fine to me so far
while further consideration might be needed.

>> For my conclusion, first option is just to drop
>> uncompleted fragments as we do today.  Second option
>> would be  to forward them to the next process so that
>> core code could send ICMPv6 etc. or, we could have
>> new code to send ICMPV6_TIME_EXCEED in REJECT target.
>> In longer term, I think it is better to introduce
>> per-exthdr hooks.
>
> I agree with your conclusion too, except a few question.
>
> It is unclear for me how can you forward the packets to the next process:
> above you pointed out that in defrag/reassembly before conntrack we do not
> know yet whether the packets are destined to the host or not. So again,
> how would you let through the fragments on conntrack then?
>
> I don't know how could the REJECT target help in any way.

Argh, more explanation.

If you unconditionally send ICMPv6, behavior would be
broken.

If you do really want to send ICMP in netfilter,
you could pretend additional rules in filter table.
For example, ICMP to be sent back only if other exthdrs
do not exist, and other packets to be silently dropped.

This cannot be our clean/final/full answer, so I said it'd
be better to introduce per-exthdr hooks in longer term.

Regards,

--yoshfuji
