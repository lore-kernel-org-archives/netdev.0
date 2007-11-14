From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH] PATCH 1/2 [SCHED 2.6.24]: Check subqueue status before calling
 hard_start_xmit
Date: Wed, 14 Nov 2007 13:58:42 +0530
Message-ID: <OF10D00FD8.804DEECF-ON65257393.002CC966-65257393.002E9303@in.ibm.com>
References: <20071113.221439.225154441.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org, peter.p.waskiewicz.jr@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp04.in.ibm.com ([59.145.155.4]:44690 "EHLO
	e28esmtp04.in.ibm.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751601AbXKNI06 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 03:26:58 -0500
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id lAE8PxwC019395
	for <netdev@vger.kernel.org>; Wed, 14 Nov 2007 13:55:59 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.6) with ESMTP id lAE8Pxme4513970
	for <netdev@vger.kernel.org>; Wed, 14 Nov 2007 13:55:59 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id lAE8PwUB022568
	for <netdev@vger.kernel.org>; Wed, 14 Nov 2007 08:25:59 GMT
In-Reply-To: <20071113.221439.225154441.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > You could optimize this by getting HARD_TX_LOCK after the check. I
> > assume that netif_stop_subqueue (from another CPU) would always be
> > called by the driver xmit, and that is not possible since we hold
> > the __LINK_STATE_QDISC_RUNNING bit. Does that sound correct?
>
> I don't think this is a critical optimization at this time,
> but something to certainly do along with the surgery
> we'll undoubtedly be doing here in the future :-)

Apologies for the spam...

I guess this check can be completely removed once other qdiscs are modified
to
support subqueue. Essentially sch_prio and sch_rr executes subqueue_stopped
twice for every skb while this check is required only for other qdiscs (and
really
belongs in the individual qdisc dequeue handlers).

Thanks,

- KK

