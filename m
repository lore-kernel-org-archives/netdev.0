From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] net: release dst entry in dev_queue_xmit()
Date: Wed, 25 Mar 2009 19:22:16 +0100
Message-ID: <49CA7658.4010400@gmail.com>
References: <49C380A6.4000904@cosmosbay.com>	<20090324.234354.43714160.davem@davemloft.net>	<49C9D99A.2040900@cosmosbay.com> <20090325.001720.238121238.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.184]:56918 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756726AbZCYSWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 14:22:37 -0400
Received: by ti-out-0910.google.com with SMTP id i7so90924tid.23
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2009 11:22:34 -0700 (PDT)
In-Reply-To: <20090325.001720.238121238.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote, On 03/25/2009 08:17 AM:

> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Wed, 25 Mar 2009 08:13:30 +0100
> 
>> If done in dev_hard_start_xmit(), skb could be requeued (because of
>> NETDEV_TX_BUSY).  Then if requeued, maybe at this time, dst being
>> NULL is not a problem ?
> 
> Usually it should be OK because the packet schedulers have
> a sort-of one-behind state that allows them to reinsert
> the SKB into their queue datastructures without reclassifying.


Actually, since David has dumped requeuing there is no reinserting;
this last one "requeued" skb is buffered at the top in q->gso_skb
and waiting for better times.

Jarek P.
