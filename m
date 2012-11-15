From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/smsc911x: Fix ready check in cases where WORD_SWAP
 is needed
Date: Wed, 14 Nov 2012 21:51:11 -0500 (EST)
Message-ID: <20121114.215111.963000574513325881.davem@davemloft.net>
References: <1352893298-20058-1-git-send-email-kamlakant.patel@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve@shawell.net,
	linus.walleij@linaro.org, robert.marklund@stericsson.com
To: kamlakant.patel@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38638 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992461Ab2KOCvM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 21:51:12 -0500
In-Reply-To: <1352893298-20058-1-git-send-email-kamlakant.patel@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Kamlakant Patel" <kamlakant.patel@broadcom.com>
Date: Wed, 14 Nov 2012 17:11:38 +0530

> The chip ready check added by the commit 3ac3546e [Always wait for
> the chip to be ready] does not work when the register read/write
> is word swapped. This check has been added before the WORD_SWAP
> register is programmed, so we need to check for swapped register
> value as well.
> 
> Bit 16 is marked as RESERVED in SMSC datasheet, Steve Glendinning
> <steve@shawell.net> checked with SMSC and wrote:
> 
>   The chip architects have concluded we should be reading PMT_CTRL
>   until we see any of bits 0, 8, 16 or 24 set.  Then we should read
>   BYTE_TEST to check the byte order is correct (as we already do).
> 
>   The rationale behind this is that some of the chip variants have
>   word order swapping features too, so the READY bit could actually
>   be in any of the 4 possible locations.  The architects have confirmed
>   that if any of these 4 positions is set the chip is ready.  The other
>   3 locations will either never be set or can only go high after READY
>   does (so also indicate the device is ready).
> 
> This change will check for the READY bit at the 16th position. We do
> not check the other two cases (bit 8 and 24) since the driver does not
> support byte-swapped register read/write.
> 
> Signed-off-by: Kamlakant Patel <kamlakant.patel@broadcom.com>

Applied, thank you.
