From: Maxime Bizon <mbizon@freebox.fr>
Subject: Re: problem forwarding IP fragments with DF bit set (caused by
 ipv4: fix path MTU discovery with connection tracking)
Date: Tue, 29 Apr 2014 17:23:41 +0200
Message-ID: <1398785021.4033.19.camel@sakura.staff.proxad.net>
References: <1398703056.12635.41.camel@sakura.staff.proxad.net>
	 <20140429143324.GB12781@macbook.localnet>
	 <1398782535.4033.11.camel@sakura.staff.proxad.net>
	 <20140429144513.GA12969@macbook.localnet>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, davem@davemloft.net,
	netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.iliad.fr ([212.27.33.1]:57275 "EHLO ns.iliad.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751016AbaD2PXm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2014 11:23:42 -0400
In-Reply-To: <20140429144513.GA12969@macbook.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2014-04-29 at 15:45 +0100, Patrick McHardy wrote:

> Right, that is not correct of course. We save the original packet size
> and should either refragment to that size or send an ICMP frag required
> if the original size exceeds the outgoing MTU.

yep indeed, if any fragment is bigger than outgoing MTU

> So your patch does look correct, however we should probably only set
> local_df in conntrack defrag.

I thought of putting it in conntrack code first, but I had some doubts.
There are a lot of possible paths that can be taken after reassembly
(ipsec, tunnel, ...), and I did not audit all of them.

Since the patch that caused this regression modified the generic
fragmentation code, it may have caused other silent breakage.

Eric/David, could I get your feeling about this ?

Thanks,

-- 
Maxime
