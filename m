From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tms380tr: fix long delays in initialization
Date: Mon, 04 Oct 2010 09:42:54 -0700 (PDT)
Message-ID: <20101004.094254.35052481.davem@davemloft.net>
References: <alpine.SOC.1.00.1010032228450.28867@math.ut.ee>
	<20101003.200109.226763463.davem@davemloft.net>
	<alpine.SOC.1.00.1010041135060.12325@math.ut.ee>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mroos@linux.ee
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47480
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756630Ab0JDQmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 12:42:33 -0400
In-Reply-To: <alpine.SOC.1.00.1010041135060.12325@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Meelis Roos <mroos@linux.ee>
Date: Mon, 4 Oct 2010 11:39:02 +0300 (EEST)

>> > tms380tr driver tries to use udelay (meaning busy loop) for several half 
>> > second delays during hardware initialization. Crazy overly long busy 
>> > wait delays mean no delay at all so driver initialization fails without 
>> > waiting. Fix it by using msleep() for long delays and leave it to 
>> > udelay() for short delays.
>> > 
>> > Signed-off-by: Meelis Roos <mroos@linux.ee>
>> 
>> You can't use msleep() here because this code can be invoked
>> from interrupts and thus cannot sleep.
> 
> I checked these two functions that contain long delays that I changed - 
> tms380tr_bringup_diags() and tms380tr_init_adapter() - to be called only 
> from tms380tr_chipset_init() that is only called from tms380tr_open() so 
> no call paths from interrupts AFAICS. Short delyas from interrupt 
> context are not changed in any way, they still use udelay().

tms380tr_init_adapter() gets called from tms380tr_chk_irq() which is
invoked from the interrupt handler.
