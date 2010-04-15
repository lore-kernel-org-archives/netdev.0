From: David Miller <davem@davemloft.net>
Subject: Re: BUG: using smp_processor_id() in preemptible [00000000] code:
 avahi-daemon: caller is netif_rx
Date: Thu, 15 Apr 2010 00:37:11 -0700 (PDT)
Message-ID: <20100415.003711.159334670.davem@davemloft.net>
References: <1271142857.16881.193.camel@edumazet-laptop>
	<20100415.001446.244372815.davem@davemloft.net>
	<l2p412e6f7f1004150030o8a406133s91d6614cbb106796@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, therbert@google.com, eparis@redhat.com,
	netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58406
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756704Ab0DOHhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 03:37:07 -0400
In-Reply-To: <l2p412e6f7f1004150030o8a406133s91d6614cbb106796@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Thu, 15 Apr 2010 15:30:44 +0800

> Should netif_rx() be used only when preemption is disabled? If not,
> netif_rx_ni() should be used instead.?

netif_rx() must be invoked from a hardware or software interrupt,
which implies preemption disabled.

In netif_rx_ni(), the "ni" means "not interrupt".
