From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next 0/7] clear old options when old qdisc's replaced
Date: Fri, 14 Feb 2014 16:36:03 +0800
Message-ID: <1392366970-11592-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <stephen@networkplumber.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:45266 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751638AbaBNIgW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 03:36:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've added a netem qdisc with rate option, then I replace this qdisc
without rate option but with latency option. The rate option is still
there.

E.g.
  # tc qdisc add dev eth4 handle 1: root netem rate 10mbit
  # tc qdisc show
    qdisc netem 1: dev eth4 root refcnt 2 limit 1000 rate 10Mbit

  # tc qdisc replace dev eth4 handle 1: root netem latency 10ms
  # tc qdisc show
    qdisc netem 1: dev eth4 root refcnt 2 limit 1000 delay 10.0ms rate 10Mbit

The old options need be cleared after the qdisc is replaced.

Yang Yingliang (7):
  sch_netem: clear old clgstate when old qdisc's replaced
  sch_netem: clear old dist table when old qdisc's replaced
  sch_netem: clear old reorder when old qdisc's replaced
  sch_netem: clear old correlation when old qdisc's replaced
  sch_netem: clear old corrupt when old qdisc's replaced
  sch_netem: clear old rate when old qdisc's replaced
  sch_netem: clear old ecn when old qdisc's replaced

 net/sched/sch_netem.c | 44 ++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 44 insertions(+)

-- 
1.8.0
