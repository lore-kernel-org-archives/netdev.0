From: Richard Cochran <richardcochran@gmail.com>
Subject: igb: acknowledging time sync interrupts
Date: Sun, 26 May 2013 12:39:00 +0200
Message-ID: <20130526103900.GA11682@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Matthew Vick <matthew.vick@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:38660 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752315Ab3EZKjK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 May 2013 06:39:10 -0400
Received: by mail-we0-f179.google.com with SMTP id m46so3742537wev.10
        for <netdev@vger.kernel.org>; Sun, 26 May 2013 03:39:08 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matt,

In igb_main.c you have ISR code like:

	if (icr & E1000_ICR_TS) {
		u32 tsicr = rd32(E1000_TSICR);

		if (tsicr & E1000_TSICR_TXTS) {
			/* acknowledge the interrupt */
			wr32(E1000_TSICR, E1000_TSICR_TXTS);
			/* retrieve hardware timestamp */
			schedule_work(&adapter->ptp_tx_work);
		}
	}

In the datasheet for the 82580 and the i210, for TSICR it says,

   Note: Once ICR.Time_Sync is set, the internal value of this
         register should be cleared by writing 1b to all bits
         or cleared by a read to enable receiving an additional
         ^^^^^^^^^^^^^^^^^^^^
         ICR.Time_Sync interrupt.

and that implies that your write to acknowledge the interrupt is
superfluous, since you already read the TSICR.

Is this an error in the datasheets, or is the code doing extra,
unneeded work?

Thanks,
Richard
