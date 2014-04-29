From: Patrick McHardy <kaber@trash.net>
Subject: Re: problem forwarding IP fragments with DF bit set (caused by ipv4:
 fix path MTU discovery with connection tracking)
Date: Tue, 29 Apr 2014 15:33:27 +0100
Message-ID: <20140429143324.GB12781@macbook.localnet>
References: <1398703056.12635.41.camel@sakura.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <edumazet@google.com>, davem@davemloft.net,
	netdev <netdev@vger.kernel.org>
To: Maxime Bizon <mbizon@freebox.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50237 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757534AbaD2Odp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2014 10:33:45 -0400
Content-Disposition: inline
In-Reply-To: <1398703056.12635.41.camel@sakura.staff.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 28, 2014 at 06:37:36PM +0200, Maxime Bizon wrote:
> 
> Hello Patrick & Eric,
> 
> After upgrading a router with a kernel that has patch 5f2d04f1f9 (ipv4:
> fix path MTU discovery with connection tracking), some packets are not
> forwarded anymore.
> 
> (note: kernel is 3.11.10, and conntrack is enabled)
> 
> Offending packets are IP fragments with DF bit set, MTU is the same on
> both interfaces involved in forwarding. All received fragments are
> (obviously) below MTU. The resulting packet after re-assembly is however
> above MTU.
> 
> conntrack causes the packets to be re-assembled, but since the resulting
> skb now has IP_DF set, it fails the (DF + MTU) test in ip_forward.c and
> causes ICMP frag_needed to be sent.

That is the correct behaviour.

> Without the patch, the packet was (re-)fragmented in the output path
> (but as the patch says, breaking PMTUD because original fragment size is
> not considered).

Yes. The sending host should receive the ICMP frag needed and adjust it's
size accordingly.
