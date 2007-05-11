From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Fri, 11 May 2007 14:02:55 +0530
Message-ID: <OFAF0AE4C2.388D2428-ON652572D8.002E0FFF-652572D8.002EF597@in.ibm.com>
References: <p73wszfenni.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: ak@suse.de, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:52888 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752652AbXEKIeQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 04:34:16 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l4B8riu8259308
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 18:53:45 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4B8bPF7147246
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 18:37:27 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4B8XpUd013647
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 18:33:52 +1000
In-Reply-To: <p73wszfenni.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andy,

ak@suse.de wrote on 05/11/2007 02:35:05 PM:

> You don't need that. You can just use the normal next/prev pointers.
> In general it's a good idea to lower lock overhead etc., the VM has
> used similar tricks very successfully in the past.

Does this mean each skb should be for the same connection if next/prev
is used ?

> Another problem is that this setup typically requires the aggregate
> packets to be from the same connection. Otherwise you will only
> safe a short trip into the stack until the linked packet would need
> to be split again to pass to multiple sockets. With that the scheme
> probably helps much less.

I guess you meant this for receives only. On the send side, packets
for different sockets can be linked and sent together, right ?

> Or you could do this only if multiple packets belong to the same
> single connection (basically with a one hit cache); but then it would

But for sends, why does same or different connection matter ? There is
no aggregating of skbs.

Thanks,

- KK

