From: David Miller <davem@davemloft.net>
Subject: Re: motive for sending Ethernet packets in soft-irq context
Date: Fri, 02 May 2008 04:23:38 -0700 (PDT)
Message-ID: <20080502.042338.83904533.davem@davemloft.net>
References: <989596.46222.qm@web30103.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: paravpandit@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58545
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752482AbYEBLXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 07:23:39 -0400
In-Reply-To: <989596.46222.qm@web30103.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Parav Pandit <paravpandit@yahoo.com>
Date: Fri, 2 May 2008 02:16:07 -0700 (PDT)

[ Your question belongs on netdev, that's where the kernel
  networking developers hang out, CC:'d ]

> What I understand is,
> It is not done into the process context of send() system call beacause,

Where did you obtain this understanding?  It's not accurate :-)

It is actually done in the send() system call thread of execution most
of the time.  soft-irqs are simply disabled during the
->hard_start_xmit() driver call so that input packet processing cannot
execute on the local cpu while this happens.

However, many packets are sent in response to received
packets.  In this case, since receive packets are
processed in soft-irq context, the response will be
sent in such a context too.

This applies for TCP data queued up waiting for the congestion
window or TCP window to open up.  When an ACK arrives which
satisfies the necessary conditions, queued up socket
data packets are send, again in soft-irq context.

So whether we send to the network card in soft-irq context
or not is entirely situation dependent.
