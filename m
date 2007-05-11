From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Fri, 11 May 2007 10:50:28 +0530
Message-ID: <OF1EF00AE2.9C32EBA0-ON652572D8.001D18D7-652572D8.001D56F1@in.ibm.com>
References: <464375F9.1050600@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>
To: Gagan Arneja <gaagaan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:38846 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754612AbXEKFVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 01:21:48 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l4B5fXsA120820
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 15:41:33 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4B5PGtb130670
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 15:25:16 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4B5Li8u019909
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 15:21:44 +1000
In-Reply-To: <464375F9.1050600@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gagan Arneja <gaagaan@gmail.com> wrote on 05/11/2007 01:13:53 AM:

> Also, I think, you don't have to chain skbs, they're already chained in
>   Qdisc->q. All you have to do is take the whole q and try to shove it
> at the device hoping for better results. But then, if you have rather
> big backlog, you run the risk of reordering packets if you have to
requeue.

I haven't seen reordering packets (I did once when I was having a bug in
the requeue code, some TCP messages on receiver indicating packets out of
order). When a send fails, the packet are requeued in reverse (go to end of
the failed skb and traverse back to the failed skb and requeue each skb).
Since new inserts go to the end, the queue is guaranteed to be in order.

Thanks,

- KK

