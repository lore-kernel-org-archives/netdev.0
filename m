From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [TG3 1/8]: Save MSI state before suspend.
Date: Tue, 13 Feb 2007 12:54:14 -0800
Message-ID: <1171400054.18944.40.camel@rh4>
References: <1171397612.18944.25.camel@rh4>
 <20070213115825.0a6119ed@freekitty>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3500 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750928AbXBMUKs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Feb 2007 15:10:48 -0500
In-Reply-To: <20070213115825.0a6119ed@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-02-13 at 11:58 -0800, Stephen Hemminger wrote:

> 
> I think you have to move the original pci_save_state call, otherwise
> you will call pci_save_state twice and leak memory.  pci_save_state
> allocates memory to store MSI and other information. Look at pci_save_pcie_state
> etc.
> 

I think it is ok the way it is.  We call pci_restore_state() at least
once during tg3_chip_reset().  This will free any memory allocated
during tg3_init_one()'s call to pci_save_state(), before we even get to
tg3_suspend().

The memory allocated in tg3_suspend()'s call to pci_save_state() will be
freed when tg3_resume() calls pci_restore_state().

