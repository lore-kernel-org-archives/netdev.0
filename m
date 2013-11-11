From: Sujith Manoharan <sujith@msujith.org>
Subject: TCP performance regression
Date: Mon, 11 Nov 2013 11:00:21 +0530
Message-ID: <21120.27501.32323.332316@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s72.web-hosting.com ([198.187.29.21]:57078 "EHLO
	s72.web-hosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751900Ab3KKFeq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 00:34:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The commit, "tcp: TSQ can use a dynamic limit" causes a large
performance drop in TCP transmission with the wireless driver ath9k.

With a 2-stream card (AR9462), the usual throughput is around 195 Mbps.
But, with this commit, it drops to ~125 Mbps, occasionally reaching 130.

If the commit is reverted, performance is normal again and I can get
190+ Mbps. Apparently, ath10k is also affected and a 250 Mbps drop
is seen (from an original 740 Mbps).

I am using Linville's wireless-testing tree.

>From the test machine:

root@linux-test ~# uname -a
Linux linux-test 3.12.0-wl-nodebug #104 SMP PREEMPT Mon Nov 11 10:27:56 IST 2013 x86_64 GNU/Linux

root@linux-test ~# tc -d -s qdisc show dev wlan0 
qdisc mq 0: root 
 Sent 342682272 bytes 226366 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 

root@linux-test ~# zgrep -i net_sch /proc/config.gz
CONFIG_NET_SCHED=y
CONFIG_NET_SCH_CBQ=m
CONFIG_NET_SCH_HTB=m
CONFIG_NET_SCH_HFSC=m
CONFIG_NET_SCH_ATM=m
CONFIG_NET_SCH_PRIO=m
CONFIG_NET_SCH_MULTIQ=m
CONFIG_NET_SCH_RED=m
CONFIG_NET_SCH_SFB=m
CONFIG_NET_SCH_SFQ=m
CONFIG_NET_SCH_TEQL=m
CONFIG_NET_SCH_TBF=m
CONFIG_NET_SCH_GRED=m
CONFIG_NET_SCH_DSMARK=m
CONFIG_NET_SCH_NETEM=m
CONFIG_NET_SCH_DRR=m
CONFIG_NET_SCH_MQPRIO=m
CONFIG_NET_SCH_CHOKE=m
CONFIG_NET_SCH_QFQ=m
CONFIG_NET_SCH_CODEL=m
CONFIG_NET_SCH_FQ_CODEL=m
CONFIG_NET_SCH_FQ=m
CONFIG_NET_SCH_INGRESS=m
# CONFIG_NET_SCH_PLUG is not set
CONFIG_NET_SCH_FIFO=y


If more information is required, please let me know.

Sujith
