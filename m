From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [GIT]: Networking
Date: Mon, 21 Jul 2008 06:40:56 +0400
Message-ID: <20080721024056.GA4800@martell.zuzino.mipt.ru>
References: <alpine.LFD.1.10.0807201751440.31863@woody.linux-foundation.org> <20080720.180304.51601407.davem@davemloft.net> <20080721010952.GA4822@martell.zuzino.mipt.ru> <20080720.181440.122144107.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:23675 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759603AbYGUCnF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2008 22:43:05 -0400
Received: by fg-out-1718.google.com with SMTP id 19so549909fgg.17
        for <netdev@vger.kernel.org>; Sun, 20 Jul 2008 19:43:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080720.181440.122144107.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OK, the problem is really this buglet:

	BUG_ON(q == &noop_qdisc);
	__netif_schedule
	netif_tx_wake_queue
	netif_wake_queue
	atl1_check_link
	atl1_up		or	atlx_link_chg_task
				run_workqueue


