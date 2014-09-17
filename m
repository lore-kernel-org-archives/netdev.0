From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: CPU scheduler to TXQ binding? (ixgbe vs. igb)
Date: Wed, 17 Sep 2014 07:32:39 -0700
Message-ID: <1410964359.7106.229.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140917152653.1c824a22@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:52270 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754061AbaIQOcm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 10:32:42 -0400
Received: by mail-pd0-f171.google.com with SMTP id p10so2242703pdj.30
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 07:32:41 -0700 (PDT)
In-Reply-To: <20140917152653.1c824a22@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-09-17 at 15:26 +0200, Jesper Dangaard Brouer wrote:
> The CPU to TXQ binding behavior of ixgbe vs. igb NIC driver are
> somehow different.  Normally I setup NIC IRQ-to-CPU bindings 1-to-1,
> with script set_irq_affinity [1].
> 
> For forcing use of a specific HW TXQ, I normally force the CPU binding
> of the process, either with "taskset" or with "netperf -T lcpu,rcpu".
> 
> This works fine with driver ixgbe, but not with driver igb.  That is
> with igb, the program forced to specific CPU, can still use another
> TXQ. What am I missing?
> 
> 
> I'm monitoring this with both:
>  1) watch -d sudo tc -s -d q ls dev ethXX
>  2) https://github.com/ffainelli/bqlmon
> 
> [1] https://github.com/netoptimizer/network-testing/blob/master/bin/set_irq_affinity

Have you setup XPS ?

echo 0001 >/sys/class/net/ethX/queues/tx-0/xps_cpus
echo 0002 >/sys/class/net/ethX/queues/tx-1/xps_cpus
echo 0004 >/sys/class/net/ethX/queues/tx-2/xps_cpus
echo 0008 >/sys/class/net/ethX/queues/tx-3/xps_cpus
echo 0010 >/sys/class/net/ethX/queues/tx-4/xps_cpus
echo 0020 >/sys/class/net/ethX/queues/tx-5/xps_cpus
echo 0040 >/sys/class/net/ethX/queues/tx-6/xps_cpus
echo 0080 >/sys/class/net/ethX/queues/tx-7/xps_cpus

Or something like that, depending on number of cpus and TX queues.
