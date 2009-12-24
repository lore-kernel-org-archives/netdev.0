From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Subject: RE: gianfar select_queue bogosity (was Re: ixgbe warning)
Date: Thu, 24 Dec 2009 11:34:23 +0530
Message-ID: <9F4C7D19E8361D4C94921B95BE08B81BA0904E@zin33exm22.fsl.freescale.net>
References: <86802c440912222100j1c23f3d9xfb734a6e52fa2ec9@mail.gmail.com><OF748A4720.94B5A869-ON65257695.00267BA3-65257695.0027EDC4@in.ibm.com> <20091223.211157.68124463.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <yinghai@kernel.org>, <e1000-devel@lists.sourceforge.net>,
	<netdev@vger.kernel.org>, <netdev-owner@vger.kernel.org>,
	<avorontsov@ru.mvista.com>, <galak@kernel.crashing.org>
To: "David Miller" <davem@davemloft.net>, <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:54717 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751572AbZLXGEi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2009 01:04:38 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20091223.211157.68124463.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net] 
>Sent: Thursday, December 24, 2009 10:42 AM
>To: krkumar2@in.ibm.com
>Cc: yinghai@kernel.org; e1000-devel@lists.sourceforge.net; 
>netdev@vger.kernel.org; netdev-owner@vger.kernel.org; 
>avorontsov@ru.mvista.com; Kumar Gopalpet-B05799; 
>galak@kernel.crashing.org
>Subject: gianfar select_queue bogosity (was Re: ixgbe warning)
>
>From: Krishna Kumar2 <krkumar2@in.ibm.com>
>Date: Wed, 23 Dec 2009 12:57:26 +0530
>
>> Also, I was looking at other providers of select_queue and found:
>> 
>> u16 gfar_select_queue(struct net_device *dev, struct sk_buff *skb) {
>>         return skb_get_queue_mapping(skb); }
>> 
>> How can this be correct (driver supports upto 8 txq's). Unless txq=0 
>> for xmits of all locally generated packets is fine.
>
>This must be fixed.  As you note the queue mapping is only set 
>for forwarding/bridging cases.
>

Yes, the queue_mapping is set for forwarding/bridginh applications.

>There is zero reason for this driver to have it's own 
>select_queue function, so the fix seems to simply remove this 
>thing altogether.
>
What if I want to maintaing a 1-1 mapping b/w the Rx/Tx queues.
For eg., I want a packet received on queue-1 on eth0 to be forwarded on
to queue-1 on eth1.

Is there some way where we can handle both kinds of applications i.e.,
forwarding/bridging and
locally  generated packets.

>Some gianfar developer please prepare such a patch, thanks.

If you want gfar_select_queue( ) function to be removed for now, I will
do that.
But, I would also want to maintain the above explained scenario to be
handled for forwarding/bridging applications.

Please provide your inputs

--

Thanks
Sandeep
