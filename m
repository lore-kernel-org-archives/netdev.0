From: Gagan Arneja <gaagaan@gmail.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Thu, 10 May 2007 22:35:47 -0700
Message-ID: <464400B3.7050404@gmail.com>
References: <OF1EF00AE2.9C32EBA0-ON652572D8.001D18D7-652572D8.001D56F1@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sceptre.pobox.com ([207.106.133.20]:53399 "EHLO
	sceptre.pobox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754568AbXEKFfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 01:35:38 -0400
In-Reply-To: <OF1EF00AE2.9C32EBA0-ON652572D8.001D18D7-652572D8.001D56F1@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Krishna Kumar2 wrote:
> I haven't seen reordering packets (I did once when I was having a bug in
> the requeue code, some TCP messages on receiver indicating packets out of
> order). When a send fails, the packet are requeued in reverse (go to end of
> the failed skb and traverse back to the failed skb and requeue each skb).
> Since new inserts go to the end, the queue is guaranteed to be in order.

queue_lock is dropped when you're in xmit. There's no guarantee packets 
won't be queued up while you're trying a transmit.

> 
> Thanks,
> 
> - KK
> 
