From: Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>
Subject: Re: [PATCH v2]IP: Send an ICMP "Fragment Reassembly Timeout"
 message when enabling connection track
Date: Tue, 26 Jan 2010 11:34:44 +0900 (JST)
Message-ID: <201001260234.o0Q2YjZk007947@toshiba.co.jp>
References: <4B599084.1060406@trash.net>
	<201001250057.o0P0v76J005243@toshiba.co.jp>
	<4B5E44A2.2080006@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yasuyuki.kozakai@toshiba.co.jp, kaber@trash.net,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, eric.dumazet@gmail.com,
	david@blue-labs.org, jorge@dti2.net, opurdila@ixiacom.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: shanwei@cn.fujitsu.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B5E44A2.2080006@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

From: Shan Wei <shanwei@cn.fujitsu.com>
Date: Tue, 26 Jan 2010 09:25:54 +0800

> Yasuyuki KOZAKAI wrote, at 01/25/2010 08:57 AM:
> > It sounds good. Please take care that IPv6 router does not reassemble
> > fragmented packets. 
> 
> I don't know the details about IPv6 router implement.
> Did you mean that we can not directly use ip6_route_input(skb) to find
> Routing type(host/router)? 

I just talked about RFC2460.

4.5  Fragment Header

   The Fragment header is used by an IPv6 source to send a packet larger
   than would fit in the path MTU to its destination.  (Note: unlike
   IPv4, fragmentation in IPv6 is performed only by source nodes, not by
   routers along a packet's delivery path -- see section 5.) 


> > IIRC the current nf_conntrack_{ipv6,reasm}.c
> > reassembles the cloned skbs for tracking, discard the cloned skbs after
> > tracking and forward the original skbs to IPv6 stack to keep the size of
> > fragmented packets.
> 
> Indeed, after assembling fragments successfully in IPv6 connection track,
> original fragments are forwarded to IPv6 stack. And then IPv6 stack
> also assembles those received fragments again.
> Thus fragments are assembled twice. 

Yes, in the case that Linux is IPv6 host.


> But IPv4 only assembly once. IPv4 connection track assembles fragments
> > successfully and then just forwards assembled intact packet to IPv4
> > stack. 
> Do you know why is IPv6 designed like that?

General speaking, IPv6 router just forwards the fragmented packets and
it's up to IPv6 host to handle them. And nf_conntrack is not packet filter,
but it just tracks packets. So I designed that nf_contrack_ipv6 forwards
fragments to IPv6 stack even if nf_conntrack detects missing piece
of fragments. This resulted in twice reassembly in the case that
Linux is IPv6 host, but I tolerated that.

I think that your improvement can remove such inefficient processing.

BTW, I explained the reason why nf_conntrack does not re-fragment
the reassembled skb like nf_conntrack_ipv4 and forwards the original
fragments to IPv6 stack in

	http://conferences.sigcomm.org/sigcomm/2007/ipv6/1569042997.pdf

Regards,

-- Yasuyuki Kozakai
