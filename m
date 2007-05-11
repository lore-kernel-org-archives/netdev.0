From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Fri, 11 May 2007 11:36:25 +0530
Message-ID: <OF04243E77.B5369513-ON652572D8.00213C30-652572D8.00218BE4@in.ibm.com>
References: <464405E2.5020409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>
To: Gagan Arneja <gaagaan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:49820 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759120AbXEKGJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 02:09:33 -0400
Received: from sd0112e0.au.ibm.com (d23rh903.au.ibm.com [202.81.18.201])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l4B6TGRC299610
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 16:29:16 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0112e0.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4B6CuQC036550
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 16:12:59 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4B67ZJO022008
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 16:07:36 +1000
In-Reply-To: <464405E2.5020409@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Gagan,

Gagan Arneja <gaagaan@gmail.com> wrote on 05/11/2007 11:27:54 AM:

> >
> > Right, but I am the sole dequeue'r, and on failure, I requeue those
packets
> > to
> > the beginning of the queue (just as it would happen in the regular case
of
> > one
> > packet xmit/failure/requeue).
>
> What about a race between trying to reacquire queue_lock and another
> failed transmit?

That is not possible too. I hold the QDISC_RUNNING bit in dev->state and
am the only sender for this device, so there is no other failed transmit.
Also, on failure of dev_hard_start_xmit, qdisc_restart will spin for the
queue lock (which could be held quickly by enqueuer's), and q->requeue()
skbs to the head of the list.

Thanks,

- KK

