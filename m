From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Thu, 10 May 2007 13:37:10 -0700 (PDT)
Message-ID: <20070510.133710.15264671.davem@davemloft.net>
References: <46435412.50800@hp.com>
	<1178820423.17393.3.camel@w-sridhar2.beaverton.ibm.com>
	<464375F9.1050600@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, rick.jones2@hp.com, krkumar2@in.ibm.com,
	johnpol@2ka.mipt.ru, netdev@vger.kernel.org
To: gaagaan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41887
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758027AbXEJUhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 16:37:07 -0400
In-Reply-To: <464375F9.1050600@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gagan Arneja <gaagaan@gmail.com>
Date: Thu, 10 May 2007 12:43:53 -0700

> It's not just small packets. The cost of calling hard_start_xmit/byte 
> was rather high on your particular device. I've seen  PCI read 
> transaction in hard_start_xmit taking ~10,000 cycles on one particular 
> device. Count the cycles your brand of NIC is taking in it's 
> xmit_routine. The worse it is, the stronger your case for cluster 
> transmits.
> 
> Also, I think, you don't have to chain skbs, they're already chained in 
>   Qdisc->q. All you have to do is take the whole q and try to shove it 
> at the device hoping for better results. But then, if you have rather 
> big backlog, you run the risk of reordering packets if you have to requeue.

If the qdisc is packed with packets and we would just loop sending
them to the device, yes it might make sense.

But if that isn't the case, which frankly is the usual case, you add a
non-trivial amount of latency by batching and that's bad exactly for
the kind of applications that send small frames.
