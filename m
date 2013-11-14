From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH 0/3] net: sched: fix some issues introduced by 64bit rates
Date: Thu, 14 Nov 2013 17:01:51 +0800
Message-ID: <1384419714-24364-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:28324 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752028Ab3KNJDN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 04:03:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TBF and HTB support 64bit rates now.
But some parameters are calulated from 32bit rates.
So calculate these parameters with rate_bytes_ps which
is the true rates.

Fix the condition of failure when rate is 0.
Fix the caculations of max_size in tbf and quantum in htb.

Yang Yingliang (3):
  net_sched: tbf: fix calculation of max_size
  net_sched: htb: fix condition of failure when rate is 0
  net_sched: htb: fix calculation of quantum

 include/net/sch_generic.h | 46 ++++++++++++++++++++++++++++++++
 net/sched/sch_htb.c       | 21 ++++++++-------
 net/sched/sch_tbf.c       | 67 ++++++++++++++++++++++++++---------------------
 3 files changed, 95 insertions(+), 39 deletions(-)

-- 
1.7.12
