From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v2]IP: Send  an ICMP "Fragment Reassembly Timeout" message
 when enabling connection track
Date: Fri, 22 Jan 2010 12:48:20 +0100
Message-ID: <4B599084.1060406@trash.net>
References: <4B57AC35.8070902@cn.fujitsu.com> <4B5844F2.30104@trash.net> <4B590BE3.40509@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	eric.dumazet@gmail.com, david@blue-labs.org, jorge@dti2.net,
	opurdila@ixiacom.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47262 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752789Ab0AVLs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 06:48:26 -0500
In-Reply-To: <4B590BE3.40509@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shan Wei wrote:
> [PATCH v2]IP: Send an ICMP "Fragment Reassembly Timeout" message when enabling connection track
> 
> No matter whether connection track is enabled, an end host should send 
> an ICMPv4 "Fragment Reassembly Timeout" message when defrag timeout. 
> The reasons are following two points:  
> 
> 1. RFC 792 says:
>    >>>> >> > >   If a host reassembling a fragmented datagram cannot complete the
>    >>>> >> > >   reassembly due to missing fragments within its time limit it
>    >>>> >> > >   discards the datagram, and it may send a time exceeded message.
>    >>>> >> > > 
>    >>>> >> > >   If fragment zero is not available then no time exceeded need be
>    >>>> >> > >   sent at all.
>    >>>> >> > > 
>    >>>> >> > > Read more: http://www.faqs.org/rfcs/rfc792.html#ixzz0aOXRD7Wp
> 
> 2. Patrick McHardy also agrees with this opinion.   :-)   
>    About the discussion of this opinion, refer to http://patchwork.ozlabs.org/patch/41649
> 
> The patch fixed the problem like this:
> When enabling connection track, fragments are received at PRE_ROUTING HOOK.
> If they are failed to reassemble, ip_expire() will be called. 
> Before sending an ICMP "Fragment Reassembly Timeout" message, 
> the patch searches router table to get the destination entry only for host type.
> 
> The patch has been tested on both host type and route type.

Looks good to me. Would you mind adding a similar change to IPv6
(net/ipv6/netfilter/nf_conntrack_reasm.c)?

