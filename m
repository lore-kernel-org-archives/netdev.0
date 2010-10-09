From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ehea: Fix a checksum issue on the receive path
Date: Sat, 09 Oct 2010 09:20:43 -0700 (PDT)
Message-ID: <20101009.092043.58419374.davem@davemloft.net>
References: <1286513130.6536.467.camel@edumazet-laptop>
	<4CAF2732.90703@linux.vnet.ibm.com>
	<1286548577.2959.412.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leitao@linux.vnet.ibm.com, netdev@vger.kernel.org, fubar@us.ibm.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33073
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756250Ab0JIQUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Oct 2010 12:20:21 -0400
In-Reply-To: <1286548577.2959.412.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 08 Oct 2010 16:36:17 +0200

> I am pretty sure most (if not all) netdev drivers pass the packet with
> invalid checksum to upper stack, so that we can increment appropriate
> SNMP counters, in IP stack or UDP/TCP/whatever stack.
> 
> tg3, bnx2, e1000, skge, sky2, bnx2x, niu, r8169, igb, ... seems to do
> that.

Drivers _must_ send up all packets, even those with bad checksums,
without exception.

Otherwise protocol statistics get lost, netfilter log entries go
missing, etc.
