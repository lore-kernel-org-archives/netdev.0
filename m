From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [RFC PATCH net-next 0/7 v2]IPv6:netfilter: defragment
Date: Thu, 25 Mar 2010 10:22:15 +0800
Message-ID: <4BAAC8D7.5050102@cn.fujitsu.com>
References: <4B88BE30.80206@cn.fujitsu.com> <4B97D34C.4020509@gmail.com> <4B98B4FC.50904@cn.fujitsu.com> <4B9B9766.3090200@linux-ipv6.org> <4B9E5FEC.9010002@trash.net> <4BA8EC4A.9070802@linux-ipv6.org> <4BA8F75E.2040303@trash.net> <4BA90F72.6010404@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	YOSHIFUJI Hideaki <hideaki.yoshifuji@gmail.com>,
	David Miller <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4BA90F72.6010404@linux-ipv6.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

yoshifuji-san:

YOSHIFUJI Hideaki wrote, at 03/24/2010 02:58 AM:
>> In this case without conntrack, IPv6 would send an ICMPv6 message,
>> so in my opinion the transparent thing to do would be to still send
>> them. Of course only if reassembly is done on an end host.
> 
> Well, no.  conntrack should just forward even uncompleted fragments
> to next process (e.g. core ipv6 code), and then the core would send
> ICMP error back.  ICMP should be sent by the core ipv6 code according
> to decision of itself, not according to netfilter.

It's bad to forward uncompleted fragments to IPv4/IPv6 stack.

One the one hand, helper modules of conntrack analyze application data
in packets. They need to parse overall segment or datagram. If packets are 
fragmented, conntrack needs to reassemble them.

On the other hand, if uncompleted fragments are forwarded to IPv4/IPv6 stack,
they will be reassemble twice, and the result is also failure.
So, conntrack will drop uncompleted fragments after reassemble timeout.
 
> Would you please explain more about what you mean by consistency
> between IPv4 and IPv6 conntrack?
> 
> I do think it is rather different, anyway (because original packets
> is to be preserved in IPv6, but not in IPv4).

Yes, the defragment implement of IPv6 conntrack is absolutely different from that of IPv4 conntrack.
But, the handle after reassemble timeout should be consistent.
For IPv4 conntrack, an end host with conntrack enabled must send ICMP fragment reassembly timeout
message to source host. Details see commit e9017b
(Title: IP: Send an ICMP "Fragment Reassembly Timeout" message when enabling connection track).

-- 
Best Regards
-----
Shan Wei

> 
> --yoshfuji
> 
 

