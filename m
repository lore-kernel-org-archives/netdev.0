From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/3] myri10ge: limit the number of recoveries
Date: Sun, 03 Jun 2007 11:55:45 -0400
Message-ID: <4662E481.4030508@garzik.org>
References: <465DCCB4.5040404@myri.com> <465DCD16.8050907@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Brice Goglin <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38418 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752414AbXFCPzr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Jun 2007 11:55:47 -0400
In-Reply-To: <465DCD16.8050907@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brice Goglin wrote:
> Limit the number of recoveries from a NIC hw watchdog reset to 1 by default.
> It enables detection of defective NICs immediately since these memory parity
> errors are expected to happen very rarely (less than once per century*NIC).
> However, a defective NIC (very rare, fortunately) can see such an error
> quite often, ie. every few minutes under high load.
> 
> Make the limit tunable to allow people with mission critical installations
> to crank up the tunable and recover an INTMAX number of times while waiting
> for a downtime window to replace the NIC. The performance won't be optimal,
> but at least, it will still work.
> 
> Signed-off-by: Brice Goglin <brice@myri.com>
> ---
>  drivers/net/myri10ge/myri10ge.c |   15 +++++++++++++--
>  1 file changed, 13 insertions(+), 2 deletions(-)

NAK.  Random broken (unrelated to silicon errata) can happen in any 
field installation, and manifest itself in any number of ways.

If defective NICs are truly rare, it does not sound worth adding this 
workaround to the driver.

If I had to guess, this is a meaningless gesture (from a technical 
standpoint) for a Big Customer(tm) who is currently throwing a 
temper-tantrum... :)

By definition if you can give them a patch, and they can wait for the 
driver patch going upstream, then it is not a "mission critical" 
situation, otherwise they would already have the patch direct from you. 
  Also, "mission critical" tends to imply that you cannot remove the 
driver from operation either, which is counter to the logic of patching 
a driver for the problem.

	Jeff



