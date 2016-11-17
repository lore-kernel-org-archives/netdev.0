From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Netperf UDP issue with connected sockets
Date: Thu, 17 Nov 2016 14:42:48 +0100
Message-ID: <20161117144248.23500001@redhat.com>
References: <20140903165943.372b897b@redhat.com>
        <1409757426.26422.41.camel@edumazet-glaptop2.roam.corp.google.com>
        <20161116131609.4e5726b4@redhat.com>
        <7c4b43a4-74bf-1ee2-6f0d-17783b5d8fcb@hpe.com>
        <20161116234022.2bad179b@redhat.com>
        <1479342849.8455.233.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161117091638.5fab8494@redhat.com>
        <1479388850.8455.240.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hpe.com>, netdev@vger.kernel.org,
        brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42082 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935006AbcKQRSm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Nov 2016 12:18:42 -0500
In-Reply-To: <1479388850.8455.240.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Nov 2016 05:20:50 -0800
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Thu, 2016-11-17 at 09:16 +0100, Jesper Dangaard Brouer wrote:
> 
> > 
> > I noticed there is a Send-Q, and the perf-top2 is _raw_spin_lock, which
> > looks like it comes from __dev_queue_xmit(), but we know from
> > experience that this stall is actually caused by writing the
> > tailptr/doorbell in the HW.  Thus, this could benefit a lot from
> > bulk/xmit_more into the qdisc layer.  
> 
> The Send-Q is there because of TX-completions being delayed a bit,
> because of IRQ mitigation.
> 
> (ethtool -c eth0)
> 
> It happens even if you do not have a qdisc in the first place.
> 
> And we do have xmit_more in the qdisc layer already.

I can see that qdisc layer does not activate xmit_more in this case.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer


$ ethtool -c mlx5p4
Coalesce parameters for mlx5p4:
Adaptive RX: on  TX: off
stats-block-usecs: 0
sample-interval: 0
pkt-rate-low: 0
pkt-rate-high: 0

rx-usecs: 3
rx-frames: 32
rx-usecs-irq: 0
rx-frames-irq: 0

tx-usecs: 16
tx-frames: 32
tx-usecs-irq: 0
tx-frames-irq: 0

rx-usecs-low: 0
rx-frame-low: 0
tx-usecs-low: 0
tx-frame-low: 0

rx-usecs-high: 0
rx-frame-high: 0
tx-usecs-high: 0
tx-frame-high: 0
