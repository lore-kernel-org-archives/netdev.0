From: David Miller <davem@davemloft.net>
Subject: Re: cxgb3 - fix race in EEH
Date: Wed, 08 Oct 2008 15:58:50 -0700 (PDT)
Message-ID: <20081008.155850.182279915.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53122
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754142AbYJHW7O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 18:59:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I've applied this patch to net-next-2.6, BUT...

You should show some signs of life and address the things
Andrew Morton asked you about when you posted this patch.

His questions and comments are included for your reference:

----------------------------------------
It's deeply weird that t3_reset_qset() does

	memset(&q->tx_reclaim_timer, 0, sizeof(q->tx_reclaim_timer));

There are lots of things in the timer_list which the driver has no
business modifying.  For example, this might break the metadata in
Thomas's debugobjects stuff, which attempts to catch things being done
in the wrong order (I don't think it will, but still...).

Rerunning init_timer() should repair the damage, but I suspect a simple

	q->tx_reclaim_timer.function = NULL;	/* explanation goes here */

would suffice here.


t3_sge_alloc_qset() could use the newer setup_timer().
----------------------------------------
