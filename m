From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET : Introduce SIOCGSTAMPNS ioctl to get timestamps
 with nanosec resolution
Date: Thu, 08 Mar 2007 20:39:29 -0800 (PST)
Message-ID: <20070308.203929.123921762.davem@davemloft.net>
References: <45E6F744.8070106@linux-foundation.org>
	<200703021538.41284.dada1@cosmosbay.com>
	<200703081517.57539.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	linux-arch@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53424
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S2992949AbXCIEj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2007 23:39:29 -0500
In-Reply-To: <200703081517.57539.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 8 Mar 2007 15:17:57 +0100

> [PATCH] NET : Introduce SIOCGSTAMPNS ioctl to get timestamps with nanosec 
> resolution
> 
> Now network timestamps use ktime_t infrastructure, we can add a new ioctl() 
> SIOCGSTAMPNS  command to get timestamps in 'struct timespec'.
> User programs can thus access to nanosecond resolution.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> CC: Stephen Hemminger <shemminger@linux-foundation.org>

Applied, thanks Eric.

This patch points out a potential compat layer problem which sh64.  It
defines the SIOCGSTAMP (and not SIOCGSTAMPNS) ioctls as not constants,
but rather constant values that depend upon the size of the structure
passed in.

But the compat bridges for these timestamp ioctls simply match on the
native ioctl value and then pass it in unchanged to the real handler.
That won't work for sh64 compat layer for 32-bit sh applications.

That's what they get for being different :-)
