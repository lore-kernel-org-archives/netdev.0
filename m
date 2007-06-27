From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] IPV6 checksum offloading in network devices
Date: Wed, 27 Jun 2007 00:44:53 -0700 (PDT)
Message-ID: <20070627.004453.55726417.davem@davemloft.net>
References: <20070530085320.0c35bd71@freepuppy>
	<465DA2A4.2060608@trash.net>
	<20070530140034.13bbf971@freepuppy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, herbert.xu@redhat.com, netdev@vger.kernel.org,
	mchan@broadcom.com
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41727
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754205AbXF0Hoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 03:44:34 -0400
In-Reply-To: <20070530140034.13bbf971@freepuppy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 30 May 2007 14:00:34 -0700

> This is better. 
> There is still a possiblity when a device allows IPV6 and not IPV4
> checksumming, that the checksum will be done in the fixup code in
> dev_queue_xmit.
> 
> The existing model for checksum offload does not correctly handle
> devices that can offload IPV4 and IPV6 only. The NETIF_F_HW_CSUM flag
> implies device can do any arbitrary protocol.
> 
> This patch:
>  * adds NETIF_F_IPV6_CSUM for those devices
>  * fixes bnx2 and tg3 devices that need it
>  * add NETIF_F_IPV6_CSUM to ipv6 output (incl GSO)
>  * fixes assumptions about NETIF_F_ALL_CSUM in nat
>  * adjusts bridge union of checksumming computation

I've applied this to net-2.6.23, we can back it out or rework
it if there are problems.

Several of these checksum feature tests are getting out of
hand :-)
