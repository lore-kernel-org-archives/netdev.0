From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [PATCH v2]IP: Send an ICMP "Fragment Reassembly Timeout" message
 when enabling connection track
Date: Tue, 26 Jan 2010 09:25:54 +0800
Message-ID: <4B5E44A2.2080006@cn.fujitsu.com>
References: <4B5844F2.30104@trash.net>	<4B590BE3.40509@cn.fujitsu.com>	<4B599084.1060406@trash.net> <201001250057.o0P0v76J005243@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	eric.dumazet@gmail.com, david@blue-labs.org, jorge@dti2.net,
	opurdila@ixiacom.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61198 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752666Ab0AZB1M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jan 2010 20:27:12 -0500
In-Reply-To: <201001250057.o0P0v76J005243@toshiba.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yasuyuki KOZAKAI wrote, at 01/25/2010 08:57 AM:
> It sounds good. Please take care that IPv6 router does not reassemble
> fragmented packets. 

I don't know the details about IPv6 router implement.
Did you mean that we can not directly use ip6_route_input(skb) to find Routing type(host/router)? 

> IIRC the current nf_conntrack_{ipv6,reasm}.c
> reassembles the cloned skbs for tracking, discard the cloned skbs after
> tracking and forward the original skbs to IPv6 stack to keep the size of
> fragmented packets.

Indeed, after assembling fragments successfully in IPv6 connection track, original fragments are forwarded to IPv6 stack. And then IPv6 stack also assembles those received fragments again.
Thus fragments are assembled twice. 

But IPv4 only assembly once. IPv4 connection track assembles fragments successfully and then just forwards assembled intact packet to IPv4 stack. 
Do you know why is IPv6 designed like that?


-- 
Best Regards
-----
Shan Wei


