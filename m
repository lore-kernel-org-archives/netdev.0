From: Andrew Victor <andrew@sanpeople.com>
Subject: Re: [PATCH 2.6.19] AT91RM9200 Ethernet update 3
Date: 05 Dec 2006 09:29:52 +0200
Message-ID: <1165303792.12510.55.camel@fuzzie.sanpeople.com>
References: <1165236624.4606.111.camel@fuzzie.sanpeople.com>
	 <20061204100831.0af6790f@freekitty>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from za-gw.sanpeople.com ([196.211.225.226]:3348 "EHLO
	za-gw.sanpeople.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966119AbWLEHjj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 02:39:39 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061204100831.0af6790f@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hi Stephen,

> Use netdev_alloc_skb instead. It sets skb->dev so you don't have to.

netdev_alloc_skb() seems to cause 2 function calls [__netdev_alloc_skb()
and __alloc_skb()], instead of just 1 for the dev_alloc_skb() case.
It might be more efficient if the driver manually sets skb->dev.


> Setting skb->len is redundant since that is what skb_put() does.

That's why that line is being removed.


> It would be best if you didn't have to copy data at all and could
> receive directly into the skb.

Probably, but then we'd need to worry about DMA and cache-aligned
skb's.  We'd also need to always allocate maximum-sized skb's;  and that
might be an issue since the AT91RM9200 is mainly used in embedded
devices where the amount of RAM can be limited.


> The existing code will cause poor realtime
> performance since the driver is copying received data with IRQ's disabled.

Only lower-priority interrupts should be disabled.


Regards,
  Andrew Victor


