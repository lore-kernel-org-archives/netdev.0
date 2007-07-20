From: Michael Neuling <mikey@neuling.org>
Subject: Possible eHEA performance issue
Date: Thu, 19 Jul 2007 20:02:04 -0700
Message-ID: <4634.1184900524@neuling.org>
Mime-Version: 1.0
Cc: anton@samba.org
To: Thomas Klein <tklein@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Stefan Roscher <ossrosch@linux.vnet.ibm.com>,
	linux-ppc <linuxppc-dev@ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:50765 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751306AbXGTDGU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2007 23:06:20 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From ehea_start_xmit in ehea_main.c we have:

    if (unlikely(atomic_read(&pr->swqe_avail) <= 1)) {
	    spin_lock_irqsave(&pr->netif_queue, flags);
	    if (unlikely(atomic_read(&pr->swqe_avail) <= 1)) {
		    pr->p_stats.queue_stopped++;
		    netif_stop_queue(dev);
		    pr->queue_stopped = 1;
	    }
	    spin_unlock_irqrestore(&pr->netif_queue, flags);
    }

Since the conditions are the same, isn't it likely that the second 'if'
is going to be taken.  Hence, shouldn't the second 'unlikely' hint be
removed or even changed to likely?

Either way, some documentation here as to why it's done this way would
be useful.  I assume the atomic_read is cheap compared to the
spin_unlock_irqsave, so we quickly check swqe_avail before we check it
again properly with the lock on so we can change some stuff.

Mikey

