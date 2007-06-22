From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [patch 0/7] CAN: Add new PF_CAN protocol family, try #3
Date: Fri, 22 Jun 2007 19:19:43 +0200
Message-ID: <467C04AF.7060006@hartkopp.net>
References: <20070622034452.28886.0@janus.isnogud.escape.de> <467BC1E9.6030201@trash.net> <467BF184.8040109@hartkopp.net> <467BF796.9080900@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Urs Thuermann <urs@isnogud.escape.de>,
	David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	netdev@vger.kernel.org, j.hadi123@gmail.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:17110 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753909AbXFVRUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2007 13:20:23 -0400
In-Reply-To: <467BF796.9080900@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Oliver Hartkopp wrote:
>
>>
>> Is it the right approach to let netif_receive_skb() set the iif-value or
>> should we better set this value on our own before invoking netif_rx()?
>>   
>
> netif_receive_skb is meant to be used as a default, the driver can
> override this if it makes sense. If you touch it anyway you might
> as well set it to the final value.

The CAN bus is really not that high sophisticated network technology, so
it does not need more than the default internal network transport
mechanics the Linux Kernel already provides in an excellent manner.

I also thought about setting skb->iif myself to ensure the correct value
to be set - maybe Jamal has also an opinion on this. The CAN bus only
transports CAN-frames with a 11/29 bit CAN-Identifier (for CSMA/CA
arbitration) with up to 8 Bytes of payload. There is no space for VLANs
and other addressing schemes that are known from Ethernet or other
network media. So in opposite to all the fancy VLANs, routing, filter,
NAT and whatever the CAN is really dumb ;-)

Regards,
Oliver


