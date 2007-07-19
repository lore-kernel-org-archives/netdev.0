From: David Miller <davem@davemloft.net>
Subject: Re: [TG3]: Fix msi issue with kexec/kdump.
Date: Wed, 18 Jul 2007 21:49:37 -0700 (PDT)
Message-ID: <20070718.214937.92582299.davem@davemloft.net>
References: <1184816447.10854.30.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tina.yang@oracle.com, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60037
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750928AbXGSEti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 00:49:38 -0400
In-Reply-To: <1184816447.10854.30.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 18 Jul 2007 20:40:47 -0700

> [TG3]: Fix msi issue with kexec/kdump.
> 
> Tina Yang <tina.yang@oracle.com> discovered an MSI related problem
> when doing kdump.  The problem is that the kexec kernel is booted
> without going through system reset, and as a result, MSI may already
> be enabled when tg3_init_one() is called.  tg3_init_one() calls
> pci_save_state() which will save the stale MSI state.  Later on in
> tg3_open(), we call pci_enable_msi() to reconfigure MSI on the chip
> before we reset the chip.  After chip reset, we call
> pci_restore_state() which will put the stale MSI address/data back
> onto the chip.
> 
> This is no longer a problem in the latest kernel because
> pci_restore_state() has been changed to restore MSI state from
> internal data structures which will guarantee restoring the proper
> MSI state.
> 
> But I think we should still fix it.  Our save and restore sequence
> can still cause very subtle problems down the road.  The fix is to
> have our own functions save and restore precisely what we need.  We
> also change it to save and restore state inside tg3_chip_reset() in a
> more straight forward way.
> 
> Thanks to Tina for helping to test and debug the problem.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Looks good, applied.

For good measure, I bumped the driver version and release date.
