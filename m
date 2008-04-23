From: Adrian Bunk <bunk@kernel.org>
Subject: mac80211/wme.c: check-after-use
Date: Wed, 23 Apr 2008 12:51:01 +0300
Message-ID: <20080423095101.GV28933@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ron Rindjunsky <ron.rindjunsky@intel.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6.pp.htv.fi ([213.243.153.40]:59419 "EHLO smtp6.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755512AbYDWJvk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2008 05:51:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Coverity checker spotted the following check-after-use of the 
"qdisc" variable in net/mac80211/wme.c introduced by
commit 9e7234923789897858e1a475c579b5e2e6ad5b74
(mac80211: A-MPDU Tx adding qdisc support):

<--  snip  -->

...
void ieee80211_requeue(struct ieee80211_local *local, int queue)
{
        struct Qdisc *root_qd = local->mdev->qdisc_sleeping;
        struct ieee80211_sched_data *q = qdisc_priv(root_qd);
        struct Qdisc *qdisc = q->queues[queue];
        struct sk_buff *skb = NULL;
        u32 len = qdisc->q.qlen;    <------

        if (!qdisc || !qdisc->dequeue)
                return;
...

<--  snip  -->

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

