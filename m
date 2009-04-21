From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/8] tg3: Allow screaming interrupt detection
Date: Tue, 21 Apr 2009 01:41:58 -0700 (PDT)
Message-ID: <20090421.014158.190780360.davem@davemloft.net>
References: <1240247955.7012@xw6200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, benli@broadcom.com,
	andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54725
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753170AbZDUImG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 04:42:06 -0400
In-Reply-To: <1240247955.7012@xw6200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Mon, 20 Apr 2009 09:55:01 -0700

> The tg3 driver's ISR is coded to accept interrupts as its own if the
> status block tag does not equal the last tag the driver has seen.  The
> last_tag field is updated from tg3_poll.  In a screaming interrupt
> situation from another device sharing tg3's IRQ, tg3_poll does not get
> a chance to be called, so the last_tag will always be out of sync with
> the status block tag.  Consequently, the driver will continually
> declare the screaming interrupts as its own, thus thwarting the
> screaming interrupt detection logic.
> 
> This patch solves the problem by creating a new last_irq_tag member and
> recording the status block tag in the ISR.  The ISR then checks the
> last_irq_tag for interrupt ownership.
> 
> Many thanks to John Marvin for the detailed bug report and analysis and
> Michael Chan for the bugfix.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Tested-by: John Marvin <jsm@fc.hp.com>

Applied.
