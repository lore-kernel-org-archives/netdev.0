From: Gagan Arneja <gaagaan@gmail.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Thu, 10 May 2007 12:43:53 -0700
Message-ID: <464375F9.1050600@gmail.com>
References: <OF305F038C.A48D4C37-ON652572D7.00538ECA-652572D7.00546E39@in.ibm.com>	 <46435412.50800@hp.com> <1178820423.17393.3.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.113.40.141]:40921 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750755AbXEJTnz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 15:43:55 -0400
In-Reply-To: <1178820423.17393.3.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> small packets belonging to the same connection could be coalesced by
> TCP, but this may help the case where multiple parallel connections are
> sending small packets.

It's not just small packets. The cost of calling hard_start_xmit/byte 
was rather high on your particular device. I've seen  PCI read 
transaction in hard_start_xmit taking ~10,000 cycles on one particular 
device. Count the cycles your brand of NIC is taking in it's 
xmit_routine. The worse it is, the stronger your case for cluster 
transmits.

Also, I think, you don't have to chain skbs, they're already chained in 
  Qdisc->q. All you have to do is take the whole q and try to shove it 
at the device hoping for better results. But then, if you have rather 
big backlog, you run the risk of reordering packets if you have to requeue.

> 
> Thanks
> Sridhar

--
Gagan

> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
