From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/2]: Convert packet scheduler hrtimers to tasklet_hrtimer
Date: Fri, 21 Aug 2009 17:03:29 -0700 (PDT)
Message-ID: <20090821.170329.163431377.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46043
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755598AbZHVADR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2009 20:03:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


tasklet_hrtimers were created as a response to how we noticed that
we had hrtimers but they expected to run in softirq context but
actually hrtimers run in hw IRQ context

This converts the two hrtimers in the packet scheduler over to
be tasklet_hrtimers.

The CAN protocol has a few hrtimers, but they fire off tasklets to
do softirq work.  So they're OK.

So after this we should be clean in the networking.
