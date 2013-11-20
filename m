From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH] usb: xhci: Link TRB must not occur with a USB payload
 burst.
Date: Wed, 20 Nov 2013 07:03:47 -0800
Message-ID: <1384959827.8604.141.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131119225822.GA9611@xanatos>
	 <Pine.LNX.4.44L0.1311192204140.6891-100000@netrider.rowland.org>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B7437@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alan Stern <stern@rowland.harvard.edu>,
	Sarah Sharp <sarah.a.sharp@linux.intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:56970 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751461Ab3KTPDu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 10:03:50 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7437@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-20 at 09:36 +0000, David Laight wrote:

> Ben said the largest number of fragments from the current network
> stack will be 17, and that none of them will cross 32k boundaries.
> So the network stack won't send down long SG lists.

Please note that skb->head itself _might_ cross a 32K or 64K boundary :

skb->head is kmalloc() provided, and SLUB can be tweaked
(slub_max_order) to use very high order pages.
