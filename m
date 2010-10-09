From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] ehea: Fix a checksum issue on the receive path
Date: Sat, 9 Oct 2010 10:31:36 -0700
Message-ID: <20101009103136.341104c5@nehalam>
References: <1286513130.6536.467.camel@edumazet-laptop>
	<4CAF2732.90703@linux.vnet.ibm.com>
	<1286548577.2959.412.camel@edumazet-laptop>
	<20101009.092043.58419374.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, leitao@linux.vnet.ibm.com,
	netdev@vger.kernel.org, fubar@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40019 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752894Ab0JIRbl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Oct 2010 13:31:41 -0400
In-Reply-To: <20101009.092043.58419374.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 09 Oct 2010 09:20:43 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 08 Oct 2010 16:36:17 +0200
> 
> > I am pretty sure most (if not all) netdev drivers pass the packet with
> > invalid checksum to upper stack, so that we can increment appropriate
> > SNMP counters, in IP stack or UDP/TCP/whatever stack.
> > 
> > tg3, bnx2, e1000, skge, sky2, bnx2x, niu, r8169, igb, ... seems to do
> > that.
> 
> Drivers _must_ send up all packets, even those with bad checksums,
> without exception.
> 
> Otherwise protocol statistics get lost, netfilter log entries go
> missing, etc.

Also hardware checksum can be wrong/broken. By passing up a packet
which the driver thinks is bad, the software can still work.
