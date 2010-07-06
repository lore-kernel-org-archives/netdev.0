From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] net: add driver hooks for time stamping.
Date: Mon, 05 Jul 2010 19:39:43 -0700 (PDT)
Message-ID: <20100705.193943.91330507.davem@davemloft.net>
References: <cover.1278307573.git.richard.cochran@omicron.at>
	<a9c79dd7d996a352b37ea4e650b235d0c8b996d1.1278307573.git.richard.cochran@omicron.at>
	<20100705.190301.48512969.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35638
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752780Ab0GFCj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 22:39:29 -0400
In-Reply-To: <20100705.190301.48512969.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 05 Jul 2010 19:03:01 -0700 (PDT)

> From: Richard Cochran <richardcochran@gmail.com>
> Date: Mon, 5 Jul 2010 07:31:07 +0200
> 
>> This patch adds hooks for transmit and receive time stamps. The
>> transmit hook allows a software fallback for transmit time stamps,
>> for MACs lacking time stamping hardware. The receive hook does not yet
>> have any effect, but it prepares the way for hardware time stamping
>> in PHY devices. Using the hooks will still require adding two inline
>> function calls to each MAC driver.
>> 
>> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
> 
> Applied.

Actually, this breaks the build.

There are drivers that never saw phylib.h included in them,
which use internal static functions named "phy_read()" and such
which match global interfaces defined in phylib.h

drivers/net/tulip/dmfe.c:334:12: error: conflicting types for 'phy_read'
include/linux/phy.h:437:19: note: previous definition of 'phy_read' was here
drivers/net/tulip/dmfe.c:335:13: error: conflicting types for 'phy_write'
include/linux/phy.h:452:19: note: previous definition of 'phy_write' was here

You're going to need to resolve this issue first, then make sure at a
minimum that an "allmodconfig" build fully passes with an
unconditional include of phylib.h in skbuff.h

I've reverted all of your patches.
