From: Joerg Roedel <joro-lkml@zlug.org>
Subject: Re: [RFC PATCH] EtherIP tunnel driver (RFC 3387)
Date: Sun, 3 Sep 2006 21:10:42 +0200
Message-ID: <20060903191042.GA6928@zlug.org>
References: <20060901151300.GA15422@zlug.org> <44F85ED8.2000907@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ironport-c10.fh-zwickau.de ([141.32.72.200]:65051 "EHLO
	ironport-c10.fh-zwickau.de") by vger.kernel.org with ESMTP
	id S932131AbWICTKp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Sep 2006 15:10:45 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <44F85ED8.2000907@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 01, 2006 at 06:24:56PM +0200, Patrick McHardy wrote:

Hello Patrick,

Thank you very much for reviewing my driver. I will fix the issues you
mentioned. But I have some explanations and questions left.

> Joerg Roedel wrote:
> > +	fl.oif = 0;
> > +	fl.nl_u.ip4_u.daddr = tunnel->parms.iph.daddr;
> > +	fl.nl_u.ip4_u.saddr = tunnel->parms.iph.saddr;
> > +	fl.nl_u.ip4_u.saddr = 0;
> > +	fl.proto = IPPROTO_ETHERIP;
> 
> This leaves fields like nfmark or iif uninitialized.

I changed the code to initialize iif to 0, but I am not sure how to
initialize the fwmark field. Neigther the ipip driver nor the sit driver
initialize this field. Is it right to initialize it to 0?

> > +		goto accept;
> > +	
> > +	if ((skb->pkt_type == PACKET_OTHERHOST) && (dev->flags & IFF_PROMISC))
> > +		goto accept;
> 
> 
> Why would you want to receive packets for other hosts picked up in
> promiscous mode?

This is because the device should be usable in a bridge to build a
distributed layer 2 network. Furthermore, this could be usefull when I
extend the driver to support multicast destinations.

> > +static void etherip_err(struct sk_buff *skb, u32 info)
> > +{
> 
> 
> You could propagte errors from destination unreachable messages
> similar to what the IPIP driver does.

I am not sure that this makes sense here. The IPIP driver handles
ICMP_FRAG_NEEDED messages. But I think those messages will never be
received by the EtherIP driver because it never sets the DF flag in the
outgoing packets (to ensure the Ethernet MTU for protocols besides IP
and IPv6). I added a comment about this issue to the etherip_tunnel_xmit
function.

This were my questions and explanations. Thanks again for reviewing, I
will submit a new patch as soon as the questions have been discussed and
the changes are tested.

Greets,
	Joerg Roedel

-- 
VGER BF report: U 0.5001
