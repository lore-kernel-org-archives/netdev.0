From: David Miller <davem@davemloft.net>
Subject: Re: pr_debug usage in raw_sendmsg
Date: Tue, 12 Apr 2011 15:33:57 -0700 (PDT)
Message-ID: <20110412.153357.116378524.davem@davemloft.net>
References: <20110412223137.GA25528@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47507
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751017Ab1DLWec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 18:34:32 -0400
In-Reply-To: <20110412223137.GA25528@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Tue, 12 Apr 2011 18:31:37 -0400

> While working on my system call fuzzer, I keep getting a lot
> of spew in dmesg from raw_sendmsg. Particularly..
> 
> [ 6442.690780] no dev
> [ 6454.257701] msg_flags 0x00000080
> [ 8055.873142] msg->msg_flags = 0xd63f35c1
> 
> Is there a good reason for keeping -DDEBUG in net/ieee802154/Makefile ?
> 
> Those messages don't look particularly helpful given there's no other context.
> (the 'no dev' one in particular looks kinda hopeless)

All of those cflags modifications in net/ieee802154/Makefile are bogus,
I'll commit the following:

--------------------
ieee802154: Remove hacked CFLAGS in net/ieee802154/Makefile

It adds -Wall (which the kernel carefully controls already) and of all
things -DDEBUG (which should be set by other means if desired, please
we have dynamic-debug these days).

Kill this noise.

Reported-by: Dave Jones <davej@redhat.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ieee802154/Makefile |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/ieee802154/Makefile b/net/ieee802154/Makefile
index ce2d335..5761185 100644
--- a/net/ieee802154/Makefile
+++ b/net/ieee802154/Makefile
@@ -1,5 +1,3 @@
 obj-$(CONFIG_IEEE802154) +=	ieee802154.o af_802154.o
 ieee802154-y		:= netlink.o nl-mac.o nl-phy.o nl_policy.o wpan-class.o
 af_802154-y		:= af_ieee802154.o raw.o dgram.o
-
-ccflags-y += -Wall -DDEBUG
-- 
1.7.4.3

