From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] declance: Restore tx descriptor ring locking
Date: Mon, 08 Jun 2009 02:42:53 -0700 (PDT)
Message-ID: <20090608.024253.54091368.davem@davemloft.net>
References: <alpine.LFD.1.10.0906080219360.6360@ftp.linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org
To: macro@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34058
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751652AbZFHJmv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 05:42:51 -0400
In-Reply-To: <alpine.LFD.1.10.0906080219360.6360@ftp.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Maciej W. Rozycki" <macro@linux-mips.org>
Date: Mon, 8 Jun 2009 02:47:05 +0100 (WEST)

> A driver overhaul on 29 Feb 2000 (!) broke locking around fiddling with 
> the tx descriptor ring in start_xmit(); a follow-on "fix" removed the 
> broken remnants altogether.  Here's a patch to restore proper locking in 
> the function -- the complement in the interrupt handler has been correct 
> all the time.
> 
>  This *may* have been the reason for the occasional confusion of the chip 
> -- triggering a tx timeout followed by a chip reset sequence -- seen on 
> R4k-based DECstations with the onboard Ethernet interface.  Another theory 
> is the confusion is due to an unindentified problem -- perhaps a silicon 
> erratum -- associated with the variation of the MT ASIC used to interface 
> the R4k CPU to the rest of the system on these computers; with its 
> aggressive write-back buffering the design is particularly weakly ordered 
> when it comes to MMIO (in the absence of ordering barriers uncached reads 
> are allowed to bypass earlier uncached writes, even if to the same 
> location), which may trigger all kinds of corner cases in peripheral 
> hardware as well as software.
> 
> Either way this piece of code is buggy.
> 
> Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>

Looks good to me, applied.
