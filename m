From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tms380tr: fix long delays in initialization
Date: Sun, 03 Oct 2010 20:01:09 -0700 (PDT)
Message-ID: <20101003.200109.226763463.davem@davemloft.net>
References: <alpine.SOC.1.00.1010032228450.28867@math.ut.ee>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mroos@linux.ee
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42242
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751403Ab0JDDAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Oct 2010 23:00:48 -0400
In-Reply-To: <alpine.SOC.1.00.1010032228450.28867@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Meelis Roos <mroos@linux.ee>
Date: Sun, 3 Oct 2010 22:34:30 +0300 (EEST)

> tms380tr driver tries to use udelay (meaning busy loop) for several half 
> second delays during hardware initialization. Crazy overly long busy 
> wait delays mean no delay at all so driver initialization fails without 
> waiting. Fix it by using msleep() for long delays and leave it to 
> udelay() for short delays.
> 
> Signed-off-by: Meelis Roos <mroos@linux.ee>

You can't use msleep() here because this code can be invoked
from interrupts and thus cannot sleep.
