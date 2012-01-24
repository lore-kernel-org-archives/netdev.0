From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: Re: [PATCH net-next] net: flow_dissector.c missing include
 linux/export.h
Date: Tue, 24 Jan 2012 22:42:44 +0100
Message-ID: <1327441364.2721.23.camel@probook>
References: <1327420643.4549.113.camel@probook>
	 <1327421731.7231.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAP=VYLr-28ZSG7tURdGbp5nG4JdOMh_GZfv0HnCxpjv+GggMLA@mail.gmail.com>
	 <20120124.155135.1784877918701583546.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: paul.gortmaker@windriver.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, sfr@canb.auug.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:36088 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750754Ab2AXVmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2012 16:42:46 -0500
In-Reply-To: <20120124.155135.1784877918701583546.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-01-24 at 15:51 -0500, David Miller wrote:
> Jesper did you actually hit this problem and get a real build
> failure? 

Yes, but I didn't explain the circumstances, sorry.

I was backporting Erics SFQ bug fix (sch_sfq: dont put new flow at the
end of flows / d47a0ac7b66) to stable kernel 3.2.1.

But to avoid conflicts I also cherry-picked the other SFQ changes, plus
the skb_flow_dissect changes, and cherry-picked:

 # sch_sfq: use skb_flow_dissect()
 # (Need flow_dissect APIs)
 git cherry-pick 11fca931d35a34d01ce209eb8d51ff667c9f5e7c

 # net: introduce skb_flow_dissect()
 git cherry-pick 0744dd00c1b1be99a25b62b1b48df440e82e57e0

 # flow_dissector: use a 64bit load/store
 git cherry-pick 4d77d2b567ec66a443792d99e96ac760991d80d0

 # sch_sfq: rehash queues in perturb timer
 git cherry-pick 225d9b89c937633dfeec502741a174fe0bab5b9f

 # sch_sfq: dont put new flow at the end of flows
 git cherry-pick  d47a0ac7b66883987275598d6039f902f4410ca9

 # net_sched: sfq: fix mem alloc error recovery
 git cherry-pick bd16a6cce2a7f169b559abc5672fd2c66e91fb36

So, I guess the "problem" is because I didn't have the patch, which adds
the include net/netprio_cgroup.h in linux/netdevice.h, and have the side
effect of including module.h, the patch:
 net: add network priority cgroup infrastructure (v4) / 5bc1421e34ecfe

git describe --contains 5bc1421e34ecfe
v3.3-rc1~182^2~519

Still think it more correct to include linux/export.h in
flow_dissector.c.

-- 
Best regards,
  Jesper Dangaard Brouer
  ComX Networks A/S
  Linux Network Kernel Developer
  Cand. Scient Datalog / MSc.CS
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
