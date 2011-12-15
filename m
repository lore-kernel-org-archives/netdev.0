From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: twice past the taps, thence out to net?
Date: Thu, 15 Dec 2011 10:44:40 -0800
Message-ID: <20111215104440.1eef9e47@s6510.linuxnetplumber.net>
References: <4EE8F884.1010304@hp.com>
	<CAGK4HS-+jj9cvvirDm96oRvRJdwC+2kjE_LnSOXBuQy0pfnQjg@mail.gmail.com>
	<1323970998.2769.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<4EEA3D58.5010101@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Vijay Subramanian <subramanian.vijay@gmail.com>,
	tcpdump-workers@lists.tcpdump.org, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46751 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756451Ab1LOSom (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Dec 2011 13:44:42 -0500
In-Reply-To: <4EEA3D58.5010101@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Dec 2011 10:32:56 -0800
Rick Jones <rick.jones2@hp.com> wrote:

> 
> > More exactly, we call dev_queue_xmit_nit() from dev_hard_start_xmit()
> > _before_ giving skb to device driver.
> >
> > If device driver returns NETDEV_TX_BUSY, and a qdisc was setup on the
> > device, packet is requeued.
> >
> > Later, when queue is allowed to send again packets, packet is
> > retransmitted (and traced a second time in dev_queue_xmit_nit())
> 
> Is this then an unintended consequence bug, or a known feature?
> 
> rick
> 
> > You can see the 'requeues' counter from "tc -s -d qdisc" output :
> >
> > qdisc mq 0: dev eth2 root
> >   Sent 29421597369 bytes 20301716 pkt (dropped 0, overlimits 0 requeues 371)
> >   backlog 0b 0p requeues 371
> 
> Sure enough:
> 
> $ tc -s -d qdisc
> qdisc mq 0: dev eth0 root
>   Sent 2212158799862 bytes 1938268098 pkt (dropped 0, overlimits 0 
> requeues 4975139)
>   backlog 0b 0p requeues 4975139
> 
> rick jones

Device's work better if the driver proactively manages stop_queue/wake_queue.
Old devices used TX_BUSY, but newer devices tend to manage the queue
themselves.
