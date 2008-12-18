From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2.6.29 v3 5/5] gianfar: Continue polling until both tx
 and rx are empty
Date: Wed, 17 Dec 2008 16:54:40 -0800 (PST)
Message-ID: <20081217.165440.259566423.davem@davemloft.net>
References: <1229550175-15600-3-git-send-email-afleming@freescale.com>
	<1229550175-15600-4-git-send-email-afleming@freescale.com>
	<1229550175-15600-5-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34340
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752739AbYLRAyj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 19:54:39 -0500
In-Reply-To: <1229550175-15600-5-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@freescale.com>
Date: Wed, 17 Dec 2008 15:42:55 -0600

> gfar_poll would declare polling done once the rx queue was empty,
> but the tx queue could still have packets left.
> 
> Stolen mostly from the e1000 driver.
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>

Applied.

But I absolutely do not recommend this polling technique at all.

The best scheme is to first purge your TX ring completely, and do not
apply any quota to this work.  It's relatively cheap and batches well.

Then, you process the RX ring and apply the quota only to the RX ring
work.

This is what every NAPI driver I've written does and it gives the best
results.
