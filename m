From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch for 2.6.27? 4/5] forcedeth: fix checksum flag
Date: Wed, 27 Aug 2008 05:57:23 -0400
Message-ID: <48B52503.8070309@garzik.org>
References: <200808202334.m7KNYbpF005035@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, aabdulla@nvidia.com, jgarzik@pobox.com,
	manfred@colorfullife.com, stable@kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42041 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753067AbYH0J51 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 05:57:27 -0400
In-Reply-To: <200808202334.m7KNYbpF005035@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Ayaz Abdulla <aabdulla@nvidia.com>
> 
> Fix the checksum feature advertised in device flags.  The hardware support
> TCP/UDP over IPv4 and TCP/UDP over IPv6 (without IPv6 extension headers). 
> However, the kernel feature flags do not distinguish IPv6 with/without
> extension headers.
> 
> Therefore, the driver needs to use NETIF_F_IP_CSUM instead of
> NETIF_F_HW_CSUM since the latter includes all IPv6 packets.
> 
> A future patch can be created to check for extension headers and perform
> software checksum calculation.
> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>
> Cc: Jeff Garzik <jgarzik@pobox.com>
> Cc: Manfred Spraul <manfred@colorfullife.com
> Cc: <stable@kernel.org>		[2.6.25.x, 2.6.26.x]
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

applied, although for future reference, read the top of 
include/linux/skbuff.h, most notably:

  *          NOTE: Even if device supports only some protocols, but
  *          is able to produce some skb->csum, it MUST use COMPLETE,
  *          not UNNECESSARY.

