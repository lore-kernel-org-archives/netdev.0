From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [GIT]: Networking
Date: Mon, 21 Jul 2008 15:50:24 +0200
Message-ID: <20080721135024.GA18320@elte.hu>
References: <20080720.104411.81744468.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:41192 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751394AbYGUNup (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2008 09:50:45 -0400
Content-Disposition: inline
In-Reply-To: <20080720.104411.81744468.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


David,

* David Miller <davem@davemloft.net> wrote:

>       e1000: remove PCI Express device IDs

networking in -git (v2.6.26-5253-g14b395e, dead e1000 interface) 
silently broke on two testboxes of mine earlier today, and i've bisected 
[*] it back to:

| d03157babed7424f5391af43200593768ce69c9a is first bad commit
| commit d03157babed7424f5391af43200593768ce69c9a
| Author: Auke Kok <auke-jan.h.kok@intel.com>
| Date:   Sun Jun 22 15:21:29 2008 -0700
|
|    e1000: remove PCI Express device IDs
|
|    We do not want to prolong the situation much longer that e1000
|    and e1000e support these devices at the same time. As a result,
|    take out the bandage that was added for the interim period
|    and remove all the PCI Express device IDs from e1000.

i have migrated these testboxes to e1000e. (i migrated a third one 
already but forgot about these two and i was stupid enough to do a 
bisection suspecting some new bug.)

I'm wondering, couldnt we warn about the removed pci express support via 
the kernel log? Some simple printk. (Perhaps also with a default-off 
.config option that shuts up this warning for users who intentionally 
boot E1000=y without e1000e support.)

Thanks,

	Ingo

[*] the bisection log:

 # bad:  [14b395e1] Merge branch 'for-2.6.27' of git://linux-nfs.org/~
 # good: [bce7f795] Linux 2.6.26
 # good: [cadc7236] Merge branch 'bkl-removal' into next
 # bad:  [a0c80b8d] pkt_sched: Make default qdisc nonshared-multiqueue
 # good: [30902dc4] ax25: Fix std timer socket destroy handling.
 # bad:  [fbd8f13a] net-sched: sch_htb: move hash and sibling list rem
 # good: [40af48c1] rt2x00: kill URB for all TX queues during disable_
 # bad:  [4977929a] iwlwifi: control 11n capabilities through module p
 # bad:  [28f49d89] Merge branch 'master' of master.kernel.org:/pub/sc
 # bad:  [0caa116d] net: sh_eth: Fix compile error sh_eth
 # good: [485ca22c] DM9000: Re-unite menuconfig entries for DM9000 dri
 # good: [177db6f0] ixgbe: add LRO support
 # bad:  [6e4f6f6f] e1000e: make ioport free
 # bad:  [d03157ba] e1000: remove PCI Express device IDs


