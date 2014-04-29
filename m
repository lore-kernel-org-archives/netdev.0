From: Patrick McHardy <kaber@trash.net>
Subject: Re: problem forwarding IP fragments with DF bit set (caused by ipv4:
 fix path MTU discovery with connection tracking)
Date: Tue, 29 Apr 2014 15:45:15 +0100
Message-ID: <20140429144513.GA12969@macbook.localnet>
References: <1398703056.12635.41.camel@sakura.staff.proxad.net>
 <20140429143324.GB12781@macbook.localnet>
 <1398782535.4033.11.camel@sakura.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <edumazet@google.com>, davem@davemloft.net,
	netdev <netdev@vger.kernel.org>
To: Maxime Bizon <mbizon@freebox.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50355 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750952AbaD2Ope (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2014 10:45:34 -0400
Content-Disposition: inline
In-Reply-To: <1398782535.4033.11.camel@sakura.staff.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 29, 2014 at 04:42:15PM +0200, Maxime Bizon wrote:
> 
> On Tue, 2014-04-29 at 15:33 +0100, Patrick McHardy wrote:
> 
> > That is the correct behaviour.
> 
> is it ?
> 
> say the remote host is sending two 1000 bytes fragments, with DF set to
> me and my MTU is 1500, I'm suppose to route these packets to an
> interface with the same MTU.
> 
> without conntrack both fragments are correctly forwarded
> 
> with conntrack, the original packet is re-assembled, then instead of
> forwarding it, we send a "frag needed mtu = 1500" to the remote host,
> which never sent any packets bigger than 1500 at the beginning.

Right, that is not correct of course. We save the original packet size
and should either refragment to that size or send an ICMP frag required
if the original size exceeds the outgoing MTU.

So your patch does look correct, however we should probably only set
local_df in conntrack defrag.
