From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC][PATCH] IP: Send a fragment reassembly time exceeded packet
 when enabling connection track
Date: Tue, 05 Jan 2010 06:44:35 +0100
Message-ID: <4B42D1C3.3020207@trash.net>
References: <4B3191E7.8060509@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B3191E7.8060509@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Shan Wei wrote:
> Default, a host may send a fragment reassembly time exceeded packet
> (ICMP Time Exceeded Message with code value of 1) when defraging fragments timeout.
> But, when enabling connection track, a host can't send the packet.
> 
> Because, the module of nf_defrag_ipv4 selected by connection track is registered 
> in PRE_ROUTING HOOK and assembles all accepted fragments(here, not begin to routing).
> After defrag timeout, the host can't send fragment reassembly time exceeded packet, 
> because of lack of router information.
> 
> RFC 792 says:
>>>>>   If a host reassembling a fragmented datagram cannot complete the
>>>>>   reassembly due to missing fragments within its time limit it
>>>>>   discards the datagram, and it may send a time exceeded message.
>>>>>
>>>>>   If fragment zero is not available then no time exceeded need be
>>>>>   sent at all.
>>>>>
>>>>>
>>>>> Read more: http://www.faqs.org/rfcs/rfc792.html#ixzz0aOXRD7Wp
> 
> So, the patch try to fix it with filling router information before sending fragment reassembly
> time exceeded packet when defrag timeout.

I guess the question is whether we really want to send an ICMP
message in this case. The above quote applies to end hosts,
while conntrack is also (probably more commonly) used on routers,
which normally shouldn't attempt reassembly. I can see no real
downside to this though except that it makes it quite easy to
discover firewalls, but that shouldn't be a real problem.
