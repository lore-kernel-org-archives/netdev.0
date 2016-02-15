From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next PATCH 1/1] net_sched fix: reclassification needs to
 consider ether protocol changes
Date: Mon, 15 Feb 2016 21:59:21 +0100
Message-ID: <56C23C29.2060101@iogearbox.net>
References: <1455565749-30951-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:55699 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753231AbcBOU70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 15:59:26 -0500
In-Reply-To: <1455565749-30951-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/15/2016 08:49 PM, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> actions could change the etherproto in particular with ethernet
> tunnelled data. Typically such actions, after peeling the outer header,
> will ask for the packet to be  reclassified. We then need to restart
> the classification with the new proto header.
>
> Example setup used to catch this:
> sudo tc qdisc add dev $ETH ingress
> sudo tc filter add dev $ETH parent ffff: prio 2 protocol 0xbeef \
> u32 match u32 0 0 flowid 1:1 \
> action ife decode reclassify

ife action is out of tree, but I believe this should be possible with
vlan action and using reclassify as tc opcode.

> Fixes: 3b3ae880266d ("net: sched: consolidate tc_classify{,_compat}")
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Has kbuild bot issues, I'd probably just move this under 'reset' label,
like:

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index b5c2cf2..af1acf0 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1852,6 +1852,7 @@ reset:
  	}

  	tp = old_tp;
+	protocol = tc_skb_protocol(skb);
  	goto reclassify;
  #endif
  }

Thanks,
Daniel
