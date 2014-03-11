From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 0/2] Don't receive packets when the napi budget == 0
Date: Tue, 11 Mar 2014 14:30:11 -0700
Message-ID: <877g808luk.fsf_-_@xmission.com>
References: <87a9cxf7mp.fsf_-_@xmission.com>
	<20140311.124907.1180556684992271103.davem@davemloft.net>
	<87wqg0cy9d.fsf@xmission.com>
	<20140311.160931.1395978386605601765.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:45453 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755493AbaCKVaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 17:30:18 -0400
In-Reply-To: <20140311.160931.1395978386605601765.davem@davemloft.net> (David
	Miller's message of "Tue, 11 Mar 2014 16:09:31 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


To the best of understanding processing any received packets when the
napi budget == 0 is broken driver behavior.  At the same time I don't
think we have ever cared before so there are a handful of drivers that
need fixes.

I care now as I will shortly be using htis in netpoll to get the
tx queue processing without the rx queue processing.

Drivers that need fixes are few and far between, and so far I have only
found two of them.  More similar patches later if I find more drivers
that need fixes.

Eric W. Biederman (2):
      bnx2: Don't receive packets when the napi budget == 0
      8139cp: Don't receive packets when the napi budget == 0

 drivers/net/ethernet/broadcom/bnx2.c  |    3 +++
 drivers/net/ethernet/realtek/8139cp.c |    5 +----
 2 files changed, 4 insertions(+), 4 deletions(-)

Eric
