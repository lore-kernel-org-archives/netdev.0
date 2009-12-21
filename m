From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [RFC] LLC_ADD/DROP_MEMBERSHIP
Date: Mon, 21 Dec 2009 23:37:44 +0200
Message-ID: <200912212337.44633.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Arnaldo Carvalho de Melo <acme@infradead.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:2860 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757166AbZLUVlF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2009 16:41:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


AFAICS there is not native multicast support for LLC sockets. One have to open 
a packet socket, do PACKET_ADD_MEMBERSHIP and keep that socket open as long as 
the LLC socket is used to receive traffic.

This is a bit awkward and also suboptimal if you need to work with a large 
number of interfaces: 

(a) using one packet socket wastes CPU cycles due to the linear packet mclist 
lookup

(b) using multiple packet sockets wastes memory

How about adding two new setsockopts for llc sockets, i.e. LLC_ADD_MEMBERSHIP 
and LLC_DROP_MEMBERSHIP to allow manipulating the multicast interface 
properties directly on LLC sockets?

If you think it is a good idea, I plan to rewrite the packet_mc_* code, move 
it to net/ethernet/ so that we can reuse it for both packet and llc sockets.

