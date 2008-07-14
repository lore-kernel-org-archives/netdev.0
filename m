From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [rfc] new sk_buff member: hwstamp
Date: Mon, 14 Jul 2008 21:30:12 +0300
Message-ID: <200807142130.12375.opurdila@ixiacom.com>
References: <200807141843.00845.opurdila@ixiacom.com> <87abgkz8bc.fsf@basil.nowhere.org> <487B9396.1060701@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:4586 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751692AbYGNScS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 14:32:18 -0400
In-Reply-To: <487B9396.1060701@hartkopp.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> However i feel, that *one* nanosec resolution timestamp (as it already
> exists inside the skbuff) is enough. AFAIK the timestamp is only set in
> the netif_rx(), when it is not already set by the driver itself. For
> that reason i would suggest to create some semi-intelligent offset
> calculation inside the driver that makes the skb->tstamp value
> correspond with the hw timestamp and therefore transports the high
> resolution timestamp requirement into the userspace.
>

You mean something like here [1] ?

The problem for this approach in our usecase (one way delay measurement) is 
that the real time clock of the CPUs (of the RX and TX ports) is not 
synchronized, but the hw timestamp (implemented in the NIC/FPGA) is. 

[1] 
http://www.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.23-rc4/2.6.23-rc4-mm1/broken-out/sky2-hardware-receive-timestamp-counter.patch

Thanks,
tavi

