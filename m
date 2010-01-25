From: Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>
Subject: Re: [PATCH v2]IP: Send an ICMP "Fragment Reassembly Timeout"
 message when enabling connection track
Date: Mon, 25 Jan 2010 09:57:06 +0900 (JST)
Message-ID: <201001250057.o0P0v8E7021320@toshiba.co.jp>
References: <4B5844F2.30104@trash.net>
	<4B590BE3.40509@cn.fujitsu.com>
	<4B599084.1060406@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shanwei@cn.fujitsu.com, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	eric.dumazet@gmail.com, david@blue-labs.org, jorge@dti2.net,
	opurdila@ixiacom.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from imx9.toshiba.co.jp ([202.33.96.51]:60155 "EHLO
	imx9.toshiba.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751229Ab0AYBDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jan 2010 20:03:16 -0500
In-Reply-To: <4B599084.1060406@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 22 Jan 2010 12:48:20 +0100

> Shan Wei wrote:
> > [PATCH v2]IP: Send an ICMP "Fragment Reassembly Timeout" message when enabling connection track
> > 
> > No matter whether connection track is enabled, an end host should send 
> > an ICMPv4 "Fragment Reassembly Timeout" message when defrag timeout. 
> > The reasons are following two points:  
> > 
> > 1. RFC 792 says:
> >    >>>> >> > >   If a host reassembling a fragmented datagram cannot complete the
> >    >>>> >> > >   reassembly due to missing fragments within its time limit it
> >    >>>> >> > >   discards the datagram, and it may send a time exceeded message.
> >    >>>> >> > > 
> >    >>>> >> > >   If fragment zero is not available then no time exceeded need be
> >    >>>> >> > >   sent at all.
> >    >>>> >> > > 
> >    >>>> >> > > Read more: http://www.faqs.org/rfcs/rfc792.html#ixzz0aOXRD7Wp
> > 
> > 2. Patrick McHardy also agrees with this opinion.   :-)   
> >    About the discussion of this opinion, refer to http://patchwork.ozlabs.org/patch/41649
> > 
> > The patch fixed the problem like this:
> > When enabling connection track, fragments are received at PRE_ROUTING HOOK.
> > If they are failed to reassemble, ip_expire() will be called. 
> > Before sending an ICMP "Fragment Reassembly Timeout" message, 
> > the patch searches router table to get the destination entry only for host type.
> > 
> > The patch has been tested on both host type and route type.
> 
> Looks good to me. Would you mind adding a similar change to IPv6
> (net/ipv6/netfilter/nf_conntrack_reasm.c)?

It sounds good. Please take care that IPv6 router does not reassemble
fragmented packets. IIRC the current nf_conntrack_{ipv6,reasm}.c
reassembles the cloned skbs for tracking, discard the cloned skbs after
tracking and forward the original skbs to IPv6 stack to keep the size of
fragmented packets.

-- Yasuyuki Kozakai
