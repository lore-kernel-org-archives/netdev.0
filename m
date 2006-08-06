From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Sun, 06 Aug 2006 00:26:44 -0700 (PDT)
Message-ID: <20060806.002644.26512828.davem@davemloft.net>
References: <1154821010.5517.48.camel@jzny2>
	<20060806025123.GA27051@gondor.apana.org.au>
	<20060806071418.GB20432@edgar.underground.se.axis.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, hadi@cyberus.ca, shemminger@osdl.org,
	mchan@broadcom.com, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:25507
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932274AbWHFH0c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Aug 2006 03:26:32 -0400
To: edgar.iglesias@axis.com
In-Reply-To: <20060806071418.GB20432@edgar.underground.se.axis.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Edgar E. Iglesias" <edgar.iglesias@axis.com>
Date: Sun, 6 Aug 2006 09:14:18 +0200

> Later I ended up throwing this away as it was causing some TCP
> connections to deadlock. If you let skb's sit in the tx-ring
> indefintely, the sk->sk_wmem_queued accounting will be inacurate and
> this was causing the TCP retransmit logic to deadlock.

That's right, it's important to release TX SKBs in a timely.  Doing it
purely from ->hard_start_xmit() causes big problems, as you saw.

Increasingly I find that orphan'ing an SKB once it hits the real
device for transmit is something to seriously consider.

