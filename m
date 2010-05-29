From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2: Fix IRQ failures during kdump.
Date: Fri, 28 May 2010 22:33:46 -0700 (PDT)
Message-ID: <20100528.223346.27796527.davem@davemloft.net>
References: <1275103462-8527-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-pci@vger.kernel.org
To: mchan@broadcom.com
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1275103462-8527-1-git-send-email-mchan@broadcom.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 28 May 2010 20:24:22 -0700

> When switching from the crashed kernel to the kdump kernel without going
> through PCI reset, IRQs may not work if a different IRQ mode is used on
> the kdump kernel.  The original IRQ mode used in the crashed kernel may
> still be enabled and the new IRQ mode may not work.  For example, it
> will fail when going from MSI-X mode to MSI mode.
> 
> We fix this by disabling MSI/MSI-X and enabling INTX in bnx2_init_board().
> 
> pci_save_state() is also moved to the end of bnx2_init_board() after
> all config register fixups (including the new IRQ fixups) have been done.
> 
> Export pci_msi_off() from drivers/pci/pci.c for this purpose.
> 
> Update bnx2 version to 2.0.16.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

I sincerely doubt that your's will be the only device which will
ever run into this issue.  Therefore handling it manually in
each and every device driver, which is the trend you will be
setting with this patch, doesn't make much sense.

Any device which uses MSI in any way can run into this scenerio,
wherein the device will be left with MSI enabled when we leave the
crash kernel and jump into the kdump kernel.

So this needs to be handled generically in the PCI layer or similar.

I'm not applying this patch.
