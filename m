From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/5] ibmvnic: harden interrupt handler
Date: Wed, 25 Jan 2017 23:04:13 -0500 (EST)
Message-ID: <20170125.230413.830821835017116629.davem@davemloft.net>
References: <1485378143-5084-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        wvoigt@us.ibm.com, nfont@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55076 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750780AbdAZEES (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 23:04:18 -0500
In-Reply-To: <1485378143-5084-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Wed, 25 Jan 2017 15:02:19 -0600

> Move most interrupt handler processing into a tasklet, and
> introduce a delay after re-enabling interrupts to fix timing
> issues encountered in hardware testing.
> 
> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

I don't think you have any idea what the real problem is.  This looks
like a hack, at best.  Next patch you'll increase the delay to "20",
right?  And if that doesn't work you'll try "40".

Or if you do know the reason, you need to explain it in detail in this
commit message so that we can properly evaluate this patch.

Furthermore, if you're going to move all of your packet processing
into software interrupt context, you might as well use NAPI polling
which is a purposefully built piece of infrastructure for doing
exactly this.
