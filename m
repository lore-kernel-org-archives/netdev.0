From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Fri, 11 May 2007 11:13:10 +0530
Message-ID: <OF3528B24A.B797EFB6-ON652572D8.001F4AB0-652572D8.001F6B22@in.ibm.com>
References: <464400B3.7050404@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>
To: Gagan Arneja <gaagaan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp05.au.ibm.com ([202.81.18.154]:50527 "EHLO
	ausmtp05.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754568AbXEKFoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 01:44:13 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp05.au.ibm.com (8.13.8/8.13.8) with ESMTP id l4B5jsix5955772
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 15:45:54 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4B5ldgD168932
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 15:47:39 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4B5i6Q1003562
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 15:44:07 +1000
In-Reply-To: <464400B3.7050404@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gagan Arneja <gaagaan@gmail.com> wrote on 05/11/2007 11:05:47 AM:

> Krishna Kumar2 wrote:
> > I haven't seen reordering packets (I did once when I was having a bug
in
> > the requeue code, some TCP messages on receiver indicating packets out
of
> > order). When a send fails, the packet are requeued in reverse (go to
end of
> > the failed skb and traverse back to the failed skb and requeue each
skb).
> > Since new inserts go to the end, the queue is guaranteed to be in
order.
>
> queue_lock is dropped when you're in xmit. There's no guarantee packets
> won't be queued up while you're trying a transmit.

Right, but I am the sole dequeue'r, and on failure, I requeue those packets
to
the beginning of the queue (just as it would happen in the regular case of
one
packet xmit/failure/requeue).

- KK

