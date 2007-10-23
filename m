From: Alexey Dobriyan <adobriyan@sw.ru>
Subject: sch_prio.c vs CONFIG_NETDEVICES_MULTIQUEUE
Date: Tue, 23 Oct 2007 16:14:20 +0400
Message-ID: <20071023121420.GB6267@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: peter.p.waskiewicz.jr@intel.com, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:15252 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751838AbXJWMOc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2007 08:14:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gcc spits following warnings

net/sched/sch_prio.c:139: warning: passing argument 2 of 'netif_subqueue_stopped' makes pointer from integer without a cast
net/sched/sch_prio.c:169: warning: passing argument 2 of 'netif_subqueue_stopped' makes pointer from integer without a cast

and he is dead right -- passing integer instead of skb is not going to
work:

	if (!netif_subqueue_stopped(sch->dev, (q->mq ? prio : 0))) {

skb_get_queue_mapping will ignore it if multiqueue support is off and
dereference it otherwise.

