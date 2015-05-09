From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: Hairpinning through net/ipv6/sit.c
Date: Sat, 9 May 2015 01:18:43 +0000
Message-ID: <2134F8430051B64F815C691A62D9831832E5DC64@XCH-BLV-504.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from blv-mbsout-02.boeing.com ([130.76.32.232]:16957 "EHLO
	blv-mbsout-02.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751167AbbEIBZc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 21:25:32 -0400
Received: from XCH-PHX-512.sw.nos.boeing.com (xch-phx-512.sw.nos.boeing.com [10.57.37.29])
	by blv-mbsout-02.boeing.com (8.14.4/8.14.4/UPSTREAM_MBSOUT) with ESMTP id t491Ijq6008419
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 8 May 2015 18:18:45 -0700
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

In ipip6_rcv() of net/ipv6/sit.c, I am trying to institute "hairpinning". By that,
I mean that when ipip6_rcv() processes an IPv6-in-IPv4 encapsulated packet
I examine IPv6 routing to see if the packet should go back out the same
interface it arrived on. If so directed by routing, I want to rewrite the IPv4
source and destination addresses and directly call ip_local_output(skb)
instead of calling netif_rx(skb). But, when I call ip_local_output(skb), the
system locks up.

Any ideas on what is happening and how to fix it? Or, any ideas on other
ways to do this kind of hairpinning?

Thanks - Fred
fred.l.templin@boeing.com
