From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [RFC PATCH net-next 0/7 v2]IPv6:netfilter: defragment
Date: Wed, 24 Mar 2010 01:28:58 +0900
Message-ID: <4BA8EC4A.9070802@linux-ipv6.org>
References: <4B88BE30.80206@cn.fujitsu.com> <4B97D34C.4020509@gmail.com> <4B98B4FC.50904@cn.fujitsu.com> <4B9B9766.3090200@linux-ipv6.org> <4B9E5FEC.9010002@trash.net>
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
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B9E5FEC.9010002@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Sorry for my slow response.

(2010/03/16 1:27), Patrick McHardy wrote:
> YOSHIFUJI Hideaki wrote:
>> (2010/03/11 18:16), Shan Wei wrote:
>>>> On the other hand, I'd even say we should NOT send
>>>> icmp here (at least by default) because standard routers
>>>> never send such packet.
>>>
>>> Yes=EF=BC=8Cfor routers, the patch-set does not send icmp message t=
o
>>> source host. It only does on destination host with IPv6 connection
>>> track enable.
>>
>> Please make it optional (via parameter) at least.
>
> The ICMP messages are only sent if the packet is destined for the
> local host, similar to what IPv6 defrag would do if conntrack wouldn'=
t
> be used. So this patch increases consistency, why should we make this
> optional?

Well, in the first place, I do think conntrack should be
transparent as much as possible.  And, I cannot find other
netfilter conntrack code (ipv4 or ipv6) sending icmp e.g.
parameter problem etc.

As I said before, I agree that netfilter may drop packets
by any reasons, but I do think it should be done silently.
It can increment netfilter's own statistic counting etc.
but it should not increment the core's (especially,
specific) statistic counting.

Reassembling processes are the same.  We should NOT send icmp, and
if ever desired, we might optionally send icmp (in other
module maybe).

Regards,

--yoshfuji
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
