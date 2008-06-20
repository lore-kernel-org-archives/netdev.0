From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/3]: v2 of "TX backlog management in-driver..."
Date: Fri, 20 Jun 2008 16:16:34 -0700 (PDT)
Message-ID: <20080620.161634.193691261.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay@linux.vnet.ibm.com, krkumar2@in.ibm.com, mchan@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48522
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756323AbYFTXQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2008 19:16:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Changes since first version:

1) Integrate TSO fixes and cleanups from Michael Chan into
   patch one.  Michael if I could have your signoff on that
   one, I'd appreciate it.

2) Patch three attempts to deal with the reordering issue and
   races as follows:

   a) ->hard_start_xmit() considers the TX ring full if any
      packets are in the TX backlog queue.  This ensures that
      the backlog is fully empties before fresh ->hard_start_xmit()
      packets can be put onto the TX ring

   b) Mimicking the existing netif_{stop,wake}_queue() machinery,
      tg3_tx() and ->hard_start_xmit() cooperate to make updates,
      tests, and memory barriers such that the the TX backlog will
      not get wedged.  There are extensive comments added to the
      code in this patch which tries to explain how this works.

Patch two is essentially unchanged.

Signed-off-by: David S. Miller <davem@davemloft.net>
