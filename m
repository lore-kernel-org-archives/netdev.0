From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net] net: dsa: bcm_sf2: Fix race condition while
 unmasking interrupts
Date: Thu, 25 Aug 2016 16:50:16 -0700 (PDT)
Message-ID: <20160825.165016.515976592954248193.davem@redhat.com>
References: <1472061680-24429-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60646 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759078AbcHYXvX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 Aug 2016 19:51:23 -0400
In-Reply-To: <1472061680-24429-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 24 Aug 2016 11:01:20 -0700

> We kept shadow copies of which interrupt sources we have enabled and
> disabled, but due to an order bug in how intrl2_mask_clear was defined,
> we could run into the following scenario:
> 
> CPU0					CPU1
> intrl2_1_mask_clear(..)
> sets INTRL2_CPU_MASK_CLEAR
> 					bcm_sf2_switch_1_isr
> 					read INTRL2_CPU_STATUS and masks with stale
> 					irq1_mask value
> updates irq1_mask value
> 
> Which would make us loop again and again trying to process and interrupt
> we are not clearing since our copy of whether it was enabled before
> still indicates it was not. Fix this by updating the shadow copy first,
> and then unasking at the HW level.
> 
> Fixes: 246d7f773c13 ("net: dsa: add Broadcom SF2 switch driver")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied and queued up for -stable, thanks.
