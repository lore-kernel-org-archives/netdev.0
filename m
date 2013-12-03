From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: vxlan/veth performance issues on net.git + latest kernels
Date: Wed, 4 Dec 2013 01:10:35 +0200
Message-ID: <CAJZOPZ+bkvg4G6qzY6YmMui9-KmGmpHyFCJUD2xsFLOXm12rgA@mail.gmail.com>
References: <CAJZOPZL9LxB5HdqS=+gQW-MjvW2NsZOt3NPB7v1iOFoEB7SsMQ@mail.gmail.com>
	<1386105850.30495.38.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAJZOPZ+vnqLpdjS0TNdxDa4CNTzzfqp1=Ftjf86Fd5Lb+QdSzw@mail.gmail.com>
	<20131203.165034.1085515763685633822.davem@davemloft.net>
	<1386107714.30495.40.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Jerry Chu <hkchu@google.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eric Dumazet <edumazet@google.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:56562 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754444Ab3LCXKg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 18:10:36 -0500
Received: by mail-pd0-f179.google.com with SMTP id r10so20977593pdi.24
        for <netdev@vger.kernel.org>; Tue, 03 Dec 2013 15:10:36 -0800 (PST)
In-Reply-To: <1386107714.30495.40.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 3, 2013 at 11:55 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2013-12-03 at 16:50 -0500, David Miller wrote:
>
>> At this point I would use drop monitor to figure out in what context
>> packets are being dropped on the floor.  There are scripts provided
>> with the perf tool to utilize it.
>
> Most easy way is to do :
>
> perf record -e skb:kfree_skb -a -g sleep 10
> perf report

$ ./perf record -e skb:kfree_skb -g -a sleep 10
$ ./perf report -i perf.data


Samples: 883K of event 'skb:kfree_skb', Event count (approx.): 883406
+  97.13%          swapper  [kernel.kallsyms]  [k] net_tx_action
+   1.53%            iperf  [kernel.kallsyms]  [k] net_tx_action
+   1.03%             perf  [kernel.kallsyms]  [k] net_tx_action
+   0.27%      ksoftirqd/7  [kernel.kallsyms]  [k] net_tx_action
+   0.03%      kworker/7:1  [kernel.kallsyms]  [k] net_tx_action
+   0.00%          rpcbind  [kernel.kallsyms]  [k] net_tx_action
+   0.00%          swapper  [kernel.kallsyms]  [k] kfree_skb
+   0.00%            sleep  [kernel.kallsyms]  [k] net_tx_action
+   0.00%  hald-addon-acpi  [kernel.kallsyms]  [k] kfree_skb
+   0.00%            iperf  [kernel.kallsyms]  [k] kfree_skb
+   0.00%             perf  [kernel.kallsyms]  [k] kfree_skb



>
>
>
