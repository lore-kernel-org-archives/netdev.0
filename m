From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] solos-pci: Fix race condition in tasklet RX handling
Date: Sat, 07 Aug 2010 23:02:22 -0700 (PDT)
Message-ID: <20100807.230222.63012624.davem@davemloft.net>
References: <1274872584.20576.13579.camel@macbook.infradead.org>
	<1281111456.2715.29.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nathan@traverse.com.au,
	linux-atm-general@lists.sourceforge.net
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40850
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750972Ab0HHGCD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Aug 2010 02:02:03 -0400
In-Reply-To: <1281111456.2715.29.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Fri, 06 Aug 2010 17:17:36 +0100

> We were seeing faults in the solos-pci receive tasklet when packets
> arrived for a VCC which was currently being closed:
 ...
> This patch uses an RCU-inspired approach to fix it. In the RX tasklet's
> find_vcc() function we first refuse to use a VCC which already has the
> ATM_VF_READY bit cleared. And in the VCC close function, we synchronise
> with the tasklet to ensure that it can't still be using the VCC before
> we continue and allow the VCC to be destroyed.
> 
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
> Tested-by: Nathan Williams <nathan@traverse.com.au>
> Cc: stable@kernel.org

Applied, thanks David.
