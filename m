From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/4] fixup IFF_NO_QUEUE conversion
Date: Thu, 27 Aug 2015 17:15:10 -0700 (PDT)
Message-ID: <20150827.171510.531165980750627399.davem@davemloft.net>
References: <1440703299-21243-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, brouer@redhat.com,
	geert@linux-m68k.org
To: phil@nwl.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48522 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752009AbbH1APL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 20:15:11 -0400
In-Reply-To: <1440703299-21243-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil@nwl.cc>
Date: Thu, 27 Aug 2015 21:21:35 +0200

> This series serves two purposes:
> 
> On one hand it fixes a quite embarrassing bug around the warning I added for
> drivers still setting tx_queue_len = 0 to achieve noqueue operation. It turned
> out to be quite useless as due to using alloc_netdev(), many in-kernel drivers
> fell into the trap by accident, as well. Instead this place serves pretty well
> as a sanitizing point to set IFF_NO_QUEUE for drivers not initializing
> tx_queue_len, which in turn allows to drop all special treatment of the latter
> being zero since that can not happen anymore without IFF_NO_QUEUE being set.
> 
> On the other hand, it provides a better solution for Eric Dumazet's concern
> regarding how to assign noqueue to an interface which does not default to it
> already. In order to make this possible, noqueue is being registered so users
> can 'tc qd add dev eth0 root noqueue'. In addition, it resolves the ugly
> situation of 'tc qd show' not showing noqueue. Finally, the former changes
> allow for some code cleanup.

Seems reasonable, series applied, thanks Phil.
