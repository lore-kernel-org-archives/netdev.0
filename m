From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: net_sched 07/07: add classful multiqueue dummy scheduler
Date: Fri, 11 Sep 2009 23:38:13 +0200
Message-ID: <20090911213812.GA3965@ami.dom.local>
References: <20090906200409.GB8833@ami.dom.local>
 <4AA50A49.7010905@trash.net>
 <20090907192429.GC4451@ami.dom.local>
 <4AA563B4.1060003@gmail.com>
 <4AA7D1B3.7010708@trash.net>
 <20090909195238.GA3043@ami.dom.local>
 <4AA8E2FB.3040809@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:53706 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753132AbZIKVig (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2009 17:38:36 -0400
Received: by fxm17 with SMTP id 17so1089638fxm.37
        for <netdev@vger.kernel.org>; Fri, 11 Sep 2009 14:38:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4AA8E2FB.3040809@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 10, 2009 at 01:28:59PM +0200, Patrick McHardy wrote:
...
> I'll remove the misleading (and unnecessary) line of code, thanks Jarek.

Btw, I guess David owes you one classful(!) dummy(?) scheduler...

Jarek P.

commit 6ec1c69a8f6492fd25722f4762721921da074c12
Author: David S. Miller <davem@davemloft.net>
Date:   Sun Sep 6 01:58:51 2009 -0700

    net_sched: add classful multiqueue dummy scheduler
    
    This patch adds a classful dummy scheduler which can be used as root qdisc
    for multiqueue devices and exposes each device queue as a child class.
    
    This allows to address queues individually and graft them similar to regular
    classes. Additionally it presents an accumulated view of the statistics of
    all real root qdiscs in the dummy root.
    
    Two new callbacks are added to the qdisc_ops and qdisc_class_ops:
    
    - cl_ops->select_queue selects the tx queue number for new child classes.
    
    - qdisc_ops->attach() overrides root qdisc device grafting to attach
      non-shared qdiscs to the queues.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/sched/sch_mq.c b/net/sched/sch_mq.c
new file mode 100644
index 0000000..c84dec9
--- /dev/null
+++ b/net/sched/sch_mq.c

