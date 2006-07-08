From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH]NET: Add ECN support for TSO
Date: Fri, 7 Jul 2006 18:01:34 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC093F9B4@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: ravinandan.arakali@neterion.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:62729 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S932476AbWGHBBr convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 21:01:47 -0400
Content-class: urn:content-classes:message
To: "David Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:

> Ok, this is correct.  TSO should simply replicate the NS bit
> because the cumulative ACK is going to be the same in each
> and every packet emitted.
> 
> 

Thanks for verifying.  However, Large Receive Offload will be
a different story.  If packets are accumulated in the hardware
and presented to the stack as one large packet, the stack will
not be able to calculate the cumulative NS correctly.  Unless
the hardware calculates the partial NS over the LRO packet and
puts it in the SKB when handing over the packet.

