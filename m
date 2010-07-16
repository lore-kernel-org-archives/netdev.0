From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ibmveth: lost IRQ while closing/opening device leads
 to service loss
Date: Fri, 16 Jul 2010 13:16:31 -0700 (PDT)
Message-ID: <20100716.131631.184859877.davem@davemloft.net>
References: <20100715202120.GA12770@linux.vnet.ibm.com>
	<20100716145724.GA25385@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, santil@linux.vnet.ibm.com,
	brking@linux.vnet.ibm.com
To: rcj@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49708
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S966137Ab0GPUQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jul 2010 16:16:15 -0400
In-Reply-To: <20100716145724.GA25385@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Jennings <rcj@linux.vnet.ibm.com>
Date: Fri, 16 Jul 2010 09:57:25 -0500

> The order of freeing the IRQ and freeing the device in firmware
> in ibmveth_close can cause the adapter to become unusable after a
> subsequent ibmveth_open.  Only a reboot of the OS will make the
> network device usable again. This is seen when cycling the adapter
> up and down while there is network activity.
> 
> There is a window where an IRQ will be left unserviced (H_EOI will not
> be called).  The solution is to make a VIO_IRQ_DISABLE h_call, free the
> device with firmware, and then call free_irq.
> 
> Signed-off-by: Robert Jennings <rcj@linux.vnet.ibm.com>

Applied, thanks.

> No changes to the patch, I realized I left out '[PATCH]' in the subject
> and I didn't want any automated tools missing this fix.

Rules may be sometimes seen as anal, but they are not _that_ anal.

Also you can always look in patchwork to see if your change is
there, and your original patch was.

You actually make more work for me if you resubmit patches already
sitting in the queue :-/
