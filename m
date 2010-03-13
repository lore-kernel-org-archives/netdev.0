From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [RFC PATCH net-next 0/7 v2]IPv6:netfilter: defragment
Date: Sat, 13 Mar 2010 22:47:18 +0900
Message-ID: <4B9B9766.3090200@linux-ipv6.org>
References: <4B88BE30.80206@cn.fujitsu.com> <4B97D34C.4020509@gmail.com> <4B98B4FC.50904@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: YOSHIFUJI Hideaki <hideaki.yoshifuji@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, yoshfuji@linux-ipv6.org
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:39548 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752884Ab0CMNr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Mar 2010 08:47:26 -0500
In-Reply-To: <4B98B4FC.50904@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

(2010/03/11 18:16), Shan Wei wrote:
> yoshifuji-san:
>
> YOSHIFUJI Hideaki wrote, at 03/11/2010 01:13 AM:
>> Well, because the context of defragment are different
>> from standard ones (e.g., In netfilter, defragment can
>> happen even on forwarding path, and the result is always
>> thrown away anyway), I think it is not a good idea to
>> touch standard MIB here. However I'm okay to increment
>> other stats like InDiscards, OurDiscards and netfilter
>> specific stats.
>
> Not only on router, but also on host, if conntrack fails to reassembl=
e
> fragments, the fragments will not be forwarded to IPv4/IPv6 stack.
> So, these fragments can't be traced from MIB counter.
>
> And, IPv4 conntrack records these fragments.
> Is the context of IPv4 defragment different from IPv6?

Yes, it is different.

As you know, defragment can not happen on routers in IPv6.
Because we do want to preserve hop-by-hop option etc,
we preserve original packets in netfilter code.

In IPv6, defragment in netfilter is a temporary just
for conntrack.  The state (including defragmented packet)
is not preserved, and original fragments are used in further
process (including local processing or forwarding).

So, please take that defragment failure is same as other
random reasons what netfilter code thinks.  Of course,
you can introduce nf-specific counters that show reasons
why packets are discarded in netfilter module.

>> On the other hand, I'd even say we should NOT send
>> icmp here (at least by default) because standard routers
>> never send such packet.
>
> Yes=EF=BC=8Cfor routers, the patch-set does not send icmp message to
> source host. It only does on destination host with IPv6 connection
> track enable.

Please make it optional (via parameter) at least.

Regards,

--yoshfuji
