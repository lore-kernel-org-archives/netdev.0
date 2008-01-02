From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: RE: [PATCH 25/26] [REVISED] atl1: add NAPI support
Date: Wed, 2 Jan 2008 11:56:36 +0900
Message-ID: <000001c84ceb$18a967c0$47e7a8c0@jason>
References: <1199152804-3889-1-git-send-email-jacliburn@bellsouth.net><1199152804-3889-26-git-send-email-jacliburn@bellsouth.net> <20080101121536.3df9c497@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <jeff@garzik.org>, <csnook@redhat.com>,
	<linux-kernel@vger.kernel.org>, <atl1-devel@lists.sourceforge.net>,
	<netdev@vger.kernel.org>, <shemminger@linux-foundation.org>
To: "'Jay Cliburn'" <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.188]:29028 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754196AbYABC5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jan 2008 21:57:22 -0500
Received: by rv-out-0910.google.com with SMTP id k20so5095874rvb.1
        for <netdev@vger.kernel.org>; Tue, 01 Jan 2008 18:57:16 -0800 (PST)
In-Reply-To: <20080101121536.3df9c497@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jay,

+	if ((work_done < budget) || !netif_running(poll_dev)) {
+quit_polling:
+		netif_rx_complete(poll_dev, napi);
+
+		if (!test_bit(__ATL1_DOWN, &adapter->flags))
+			atlx_irq_enable(adapter);
+	}

Not enough :)
If netif_running() is false, it can make problem.
The problem occurs calling netif_rx_complete with work_done == budget.
If do that, net_rx_action would do poll list double deletion.

Since we had reached a consensus on fixing it without each drivers modifications, there is no best solution for that problem for
now. I'm expecting Dave or others work for net-core.
(http://lkml.org/lkml/2007/12/20/600)

IMHO, atl1_clean should wait for work_done != budget even though netif_running is false at this time.
At least, It would not make oops.

Thanks,
Joonwoo

