From: Maxime Bizon <mbizon@freebox.fr>
Subject: Re: problem forwarding IP fragments with DF bit set (caused by
 ipv4: fix path MTU discovery with connection tracking)
Date: Tue, 29 Apr 2014 16:42:15 +0200
Message-ID: <1398782535.4033.11.camel@sakura.staff.proxad.net>
References: <1398703056.12635.41.camel@sakura.staff.proxad.net>
	 <20140429143324.GB12781@macbook.localnet>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, davem@davemloft.net,
	netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.iliad.fr ([212.27.33.1]:54637 "EHLO ns.iliad.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757943AbaD2OmR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2014 10:42:17 -0400
In-Reply-To: <20140429143324.GB12781@macbook.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2014-04-29 at 15:33 +0100, Patrick McHardy wrote:

> That is the correct behaviour.

is it ?

say the remote host is sending two 1000 bytes fragments, with DF set to
me and my MTU is 1500, I'm suppose to route these packets to an
interface with the same MTU.

without conntrack both fragments are correctly forwarded

with conntrack, the original packet is re-assembled, then instead of
forwarding it, we send a "frag needed mtu = 1500" to the remote host,
which never sent any packets bigger than 1500 at the beginning.

-- 
Maxime
