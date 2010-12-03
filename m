From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 06/17] sfc: Fix event based MCDI
 completion and MC REBOOT/CMDDONE ordering issue
Date: Fri, 03 Dec 2010 09:09:04 -0800 (PST)
Message-ID: <20101203.090904.112597272.davem@davemloft.net>
References: <1291333490.3259.23.camel@bwh-desktop>
	<1291333615.3259.29.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42671
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752393Ab0LCRIh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 12:08:37 -0500
In-Reply-To: <1291333615.3259.29.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 02 Dec 2010 23:46:55 +0000

> From: Steve Hodgson <shodgson@solarflare.com>
> 
> The mcfw *never* sends CMDDONE when rebooting. Changing this so that it always
> sends CMDDONE *before* REBOOT is easy on Siena, but it's not obvious that we
> could guarantee to be able to implement this on future hardware.
> 
> Given this, I'm less convinced that the protocol should be changed.
> 
> To reiterate the failure mode: The driver sees this:
> 
>  issue command
>  receive REBOOT event
> 
> Was that reboot event sent before the command was issued, or in
> response to the command? If the former then there will be a subsequent
> CMDDONE event, if the latter, then there will be no CMDDONE event.
> 
> Options to resolve this are:
> 
>  1. REBOOT always completes an outstanding mcdi request, and we set
>     the credits count to ignore a subsequent CMDDONE event with
>     mismatching seqno.
> 
>  2. REBOOT never completes an outstanding mcdi request. If there is
>     no CMDDONE event then we rely on the mcdi timeout code to complete
>     the outstanding request, incurring a 10s delay.
> 
> I'd argue that (2) is tidier, but that incurring a 10s delay is a little
> needless. Let's go with (1).
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
