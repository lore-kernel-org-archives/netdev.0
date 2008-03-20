From: David Miller <davem@davemloft.net>
Subject: Re: drivers/net/niu.c: memcpy(dev->dev_addr, dev->perm_addr,
 dev->addr_len)?
Date: Thu, 20 Mar 2008 14:25:10 -0700 (PDT)
Message-ID: <20080320.142510.148381731.davem@davemloft.net>
References: <47E2D08E.5050708@tiscali.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: 12o3l@tiscali.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56966
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756026AbYCTVYx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 17:24:53 -0400
In-Reply-To: <47E2D08E.5050708@tiscali.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <12o3l@tiscali.nl>
Date: Thu, 20 Mar 2008 22:01:02 +0100

> in drivers/net/niu.c, line 6406, 6286 and 7173:
> 
> memcpy(dev->dev_addr, dev->perm_addr, dev->addr_len);
> 
> I noticed that "
> 
> memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len)
> 
> occurs much more often (15x). could it be that the first two arguments
> are swapped in niu.c?

No, these calls are correct.  We are probing the device's permanent
ethernet address, we first place it into dev->dev_addr and then we
copy it into dev->perm_addr.

Please try to actually understand the pieces of strcpy and memcpy code
you are "finding bugs" in before posting to the list as these analysis
on false positives are going to eat up a lot of developer time.

I notice you posting several of these kinds of things.
