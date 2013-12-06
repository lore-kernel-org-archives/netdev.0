From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: vxlan/veth performance issues on net.git + latest kernels
Date: Fri, 6 Dec 2013 11:06:45 +0200
Message-ID: <CAJZOPZK8UnjGYDdZ4=6BQq55WviSkKA36WHfsmk03u6S7BxZNA@mail.gmail.com>
References: <CAJZOPZL9LxB5HdqS=+gQW-MjvW2NsZOt3NPB7v1iOFoEB7SsMQ@mail.gmail.com>
	<1386105850.30495.38.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAJZOPZ+vnqLpdjS0TNdxDa4CNTzzfqp1=Ftjf86Fd5Lb+QdSzw@mail.gmail.com>
	<20131203.165034.1085515763685633822.davem@davemloft.net>
	<1386107714.30495.40.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAJZOPZ+bkvg4G6qzY6YmMui9-KmGmpHyFCJUD2xsFLOXm12rgA@mail.gmail.com>
	<1386115199.30495.44.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAMEtUuzEM957fRjsb5aSG7xHWKp13fy59QxWpsU_=d+-6ydazg@mail.gmail.com>
	<1386117362.30495.49.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAMEtUuy8HA1nOQJTnxy+p7vNFV25zxMAmz1fh2spj0k4hYgh4w@mail.gmail.com>
	<1386120216.30495.59.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Jerry Chu <hkchu@google.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eric Dumazet <edumazet@google.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:40430 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756106Ab3LFJGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 04:06:46 -0500
Received: by mail-pb0-f48.google.com with SMTP id md12so717239pbc.35
        for <netdev@vger.kernel.org>; Fri, 06 Dec 2013 01:06:45 -0800 (PST)
In-Reply-To: <1386120216.30495.59.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 4, 2013 at 3:23 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> skb->dev is in the first cache line, where we access skb->next anyway.
> I could use skb->cb[] like the following patch :

Hi Eric, I applied on the net tree the patch you posted yesterday
"net: introduce dev_consume_skb_any()" along with the network drivers
part of this patch, unless I got it wrong, I assume both pieces are
needed?

So I re-run the vxlan/veth test that we suspect goes through packet drops on TX.

With the patches applied I have almost no samples of that event

$ ./perf report -i perf.data

Samples: 89  of event 'skb:kfree_skb', Event count (approx.): 89
+  39.33%  ksoftirqd/2  [kernel.kallsyms]  [k] net_tx_action

                    ?
+  28.09%      swapper  [kernel.kallsyms]  [k] net_tx_action

                    ?
+  28.09%         sshd  [kernel.kallsyms]  [k] net_tx_action

                    ?
+   2.25%      swapper  [kernel.kallsyms]  [k] kfree_skb

                    ?
+   1.12%  kworker/2:2  [kernel.kallsyms]  [k] net_tx_action

                    ?
+   1.12%        iperf  [kernel.kallsyms]  [k] net_tx_action

 ./perf report -i perf.data --sort dso,symbol
Samples: 89  of event 'skb:kfree_skb', Event count (approx.): 89
+  97.75%  [kernel.kallsyms]  [k] net_tx_action
+   2.25%  [kernel.kallsyms]  [k] kfree_skb
