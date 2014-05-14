From: Michael Chan <mchan@broadcom.com>
Subject: Re: [PATCH] use cond_resched() to replace udelay() when dump eeprom
Date: Tue, 13 May 2014 22:41:29 -0700
Message-ID: <1400046089.7000.27.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1399878384-4690-1-git-send-email-acho@suse.com>
	 <1399916910.7000.16.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <20140514.005330.276486541596607753.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: <acho@suse.com>, <netdev@vger.kernel.org>, <bpoirier@suse.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:11315 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919AbaENGYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 02:24:43 -0400
In-Reply-To: <20140514.005330.276486541596607753.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-05-14 at 00:53 -0400, David Miller wrote: 
> From: Michael Chan <mchan@broadcom.com>
> Date: Mon, 12 May 2014 10:48:30 -0700
> 
> > We still need to time these commands.  Using cond_resched(), the timing
> > becomes unpredictable.  Perhaps we can reduce the NVRAM_CMD_TIMEOUT
> > counter by a factor of 100 and use msleep(1) instead of udelay(10).
> 
> That should work.

It actually won't work very well.  It typically takes 10 to 20 us to
read one 32-bit value.  Using msleep(1), it will take 100 times longer
than it should.  When dumping the entire NVRAM, it will visibly take a
very long time.

We are working on a patch to make sure that the clock is not running
slow when reading the NVRAM.  I think we can also reduce
NVRAM_CMD_TIMEOUT to something more reasonable.
