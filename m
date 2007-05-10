From: Gagan Arneja <gaagaan@gmail.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Thu, 10 May 2007 14:50:19 -0700
Message-ID: <4643939B.3000904@gmail.com>
References: <46435412.50800@hp.com><OF5ECC8062.FEB97ADC-ON882572D7.0075648E-882572D7.0075E0A6@us.ibm.com> <20070510.144007.62663063.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, rick.jones2@hp.com, johnpol@2ka.mipt.ru,
	krkumar2@in.ibm.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.113.40.141]:59833 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754560AbXEJVuV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 17:50:21 -0400
In-Reply-To: <20070510.144007.62663063.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:

> Right.
> 
> But I think it's critical to do two things:
> 
> 1) Do this when netif_wake_queue() is triggers and thus the
>    TX is locked already.
> 
> 2) Have some way for the driver to say how many free TX slots
>    there are in order to minimize if not eliminate requeueing
>    during this batching thing.

I don't think you can reliably do this. Jumbograms may end up taking 
more than one slot.

> 
> If you drop the TX lock, the number of free slots can change
> as another cpu gets in there queuing packets.

Can you ever have more than one thread inside the driver? Isn't 
xmit_lock held while we're in there?

--
Gagan

