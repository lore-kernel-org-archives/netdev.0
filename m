From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: Fix oversized packets handling
Date: Wed, 16 Jun 2010 18:09:49 -0700 (PDT)
Message-ID: <20100616.180949.258118943.davem@davemloft.net>
References: <20100611205103.GA4255@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Sandeep.Kumar@freescale.com, afleming@freescale.com,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: avorontsov@mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57007
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755009Ab0FQBJh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 21:09:37 -0400
In-Reply-To: <20100611205103.GA4255@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Vorontsov <avorontsov@mvista.com>
Date: Sat, 12 Jun 2010 00:51:03 +0400

> Issuing the following command on host:
> 
> $ ifconfig eth2 mtu 1600 ; ping 10.0.0.27 -s 1485 -c 1
> 
> Makes some boards (tested with MPC8315 rev 1.1 and MPC8313 rev 1.0)
> oops like this:
 ...
> Dumped buffer descriptors showed that eTSEC's length/truncation
> logic sometimes passes oversized packets, i.e. for the above ICMP
> packet the following two buffer descriptors may become ready:
> 
>   status=1400 length=1536
>   status=1800 length=1541
> 
> So, it seems that gianfar actually receives the whole big frame,
> and it tries to place the packet into two BDs. This situation
> confuses the driver, and so the skb_put() sanity check fails.
> 
> This patch fixes the issue by adding an appropriate check, i.e.
> the driver should not try to process frames with buffer
> descriptor's length over rx_buffer_size (i.e. maxfrm and mrblr).
> 
> Note that sometimes eTSEC works correctly, i.e. in the second
> (last) buffer descriptor bits 'truncated' and 'crcerr' are set,
> and so there's no oops. Though I couldn't find any logic when
> it works correctly and when not.
> 
> Signed-off-by: Anton Vorontsov <avorontsov@mvista.com>

Applied, thanks Anton.
