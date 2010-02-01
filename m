From: Maxime Bizon <mbizon@freebox.fr>
Subject: Re: [PATCH ver2] Avoid enqueuing skb for default qdiscs
Date: Mon, 01 Feb 2010 15:16:34 +0100
Message-ID: <1265033794.32192.54.camel@sakura.staff.proxad.net>
References: <20090806114421.19208.39374.sendpatchset@localhost.localdomain>
	 <1265017940.32192.23.camel@sakura.staff.proxad.net>
	 <OF6B2AD304.3AD05621-ON652576BD.0047556A-652576BD.004B1F23@in.ibm.com>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	Jarek Poplawski <jarkao2@gmail.com>, kaber@trash.net,
	netdev@vger.kernel.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:46793 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753297Ab0BAOQo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Feb 2010 09:16:44 -0500
In-Reply-To: <OF6B2AD304.3AD05621-ON652576BD.0047556A-652576BD.004B1F23@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2010-02-01 at 19:12 +0530, Krishna Kumar2 wrote:

Hi,

> sch_direct_xmit can be called from dev_queue_xmit for a
> stopped device only if the device had xmit the previous
> skb, stopped the device and returned OK. Then the next

Yes, that's what happen in my case.

> BTW, I don't think this patch would change the earlier
> behavior. The old code would have done the same thing.

Oh, my mistake then. I always thought the requeue counter was indicating
the driver returned TX_BUSY (and failed to stop the queue before), which
is not polite.

If the current behavior is the expected one, then there is no problem
here.

> As I explained, this should happen only once per stop event.
> Could you tell which driver is having this problem? Is it
> waking up too early, eg, it might be stopping when the hw tx
> descriptor is full but waking up when a few slots open up,
> and those will get filled up immediately on fast systems.
> Then you will see a lot of requeue's.

This is an atm driver which is not mainlined. The system is not that
fast, but the link is (very) slow (< 1 Mbit/s).

The driver is waking up the queue once the hardware queue is not full
anymore (at least one free tx desc), and the free slot gets filled
immediately since the link is slow.

Thanks for explaining !

-- 
Maxime


