From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC PATCH] EtherIP tunnel driver (RFC 3387)
Date: Mon, 04 Sep 2006 00:22:34 +0200
Message-ID: <44FB55AA.4000809@trash.net>
References: <20060901151300.GA15422@zlug.org> <44F85ED8.2000907@trash.net> <20060903191042.GA6928@zlug.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:1192 "EHLO stinky.trash.net")
	by vger.kernel.org with ESMTP id S1751152AbWICWZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2006 18:25:19 -0400
To: Joerg Roedel <joro-lkml@zlug.org>
In-Reply-To: <20060903191042.GA6928@zlug.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joerg Roedel wrote:
> On Fri, Sep 01, 2006 at 06:24:56PM +0200, Patrick McHardy wrote:
>>
>>>+	fl.oif = 0;
>>>+	fl.nl_u.ip4_u.daddr = tunnel->parms.iph.daddr;
>>>+	fl.nl_u.ip4_u.saddr = tunnel->parms.iph.saddr;
>>>+	fl.nl_u.ip4_u.saddr = 0;
>>>+	fl.proto = IPPROTO_ETHERIP;
>>
>>This leaves fields like nfmark or iif uninitialized.
> 
> 
> I changed the code to initialize iif to 0, but I am not sure how to
> initialize the fwmark field. Neigther the ipip driver nor the sit driver
> initialize this field. Is it right to initialize it to 0?

They both initialize the entire structure at once, which sets members
not explicitly initialized to zero.

>>>+		goto accept;
>>>+	
>>>+	if ((skb->pkt_type == PACKET_OTHERHOST) && (dev->flags & IFF_PROMISC))
>>>+		goto accept;
>>
>>
>>Why would you want to receive packets for other hosts picked up in
>>promiscous mode?
> 
> 
> This is because the device should be usable in a bridge to build a
> distributed layer 2 network. Furthermore, this could be usefull when I
> extend the driver to support multicast destinations.

Yes, I totally misunderstood the intention.

>>>+static void etherip_err(struct sk_buff *skb, u32 info)
>>>+{
>>
>>
>>You could propagte errors from destination unreachable messages
>>similar to what the IPIP driver does.
> 
> 
> I am not sure that this makes sense here. The IPIP driver handles
> ICMP_FRAG_NEEDED messages. But I think those messages will never be
> received by the EtherIP driver because it never sets the DF flag in the
> outgoing packets (to ensure the Ethernet MTU for protocols besides IP
> and IPv6). I added a comment about this issue to the etherip_tunnel_xmit
> function.

Thanks for the explanation, I didn't notice that it doesn't set DF.

-- 
VGER BF report: U 0.505164
