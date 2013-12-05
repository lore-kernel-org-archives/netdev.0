From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: Possible IPv6 fragmentation/pmtud bug
Date: Thu, 5 Dec 2013 19:39:52 +0000
Message-ID: <2134F8430051B64F815C691A62D9831816F612@XCH-BLV-504.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slb-mbsout-02.boeing.com ([130.76.64.129]:56248 "EHLO
	slb-mbsout-02.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752046Ab3LETrz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 14:47:55 -0500
Received: from XCH-PHX-312.sw.nos.boeing.com (xch-phx-312.sw.nos.boeing.com [130.247.25.173])
	by slb-mbsout-02.boeing.com (8.14.4/8.14.4/UPSTREAM_MBSOUT) with ESMTP id rB5JdrF4010502
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 5 Dec 2013 11:39:53 -0800
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have the following test network configuration (all linux nodes
running the 3.10.17 kernel):


h1 <-----------> r1 <-----------> r2 <-----------> h2
   8000 MTU link    4000 MTU link    8000 MTU link

When host h1 ping6's host h2, routers r1 and r2 forward the ICMPv6
echo request/reply packets as expected. But, when I set a ping6
packet size that is larger than the router-to-router link MTU:

  h1# ping6 -s 5000 h2

router r1 does NOT send an ICMPv6 Packet Too Big message back
to host h1 but rather fragments the ICMPv6 echo request packets
itself before forwarding on to router r2 then ultimately host h1.
The ping6's still succeed because of IPv6 fragmentation, but it
is *router r1* that is doing the fragmentation instead of host h1.

This seems to be related to the setting of the "skb->local_df" flag,
which should only be set for locally-generated packets; not for
packets that are being forwarded by a router. Does anyone have any
idea as to why my router is performing fragmentation when it forwards
an ICMPv6 packet?

Thanks - Fred
fred.l.templin@boeing.com
