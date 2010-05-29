From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] bnx2: Fix IRQ failures during kdump.
Date: Sat, 29 May 2010 09:01:56 -0700
Message-ID: <20100529090156.29067f28@nehalam>
References: <1275103462-8527-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1275103462-8527-1-git-send-email-mchan@broadcom.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 28 May 2010 20:24:22 -0700
"Michael Chan" <mchan@broadcom.com> wrote:

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

This is probably a generic problem for many drivers. So why not
get the kdump code to fix it for all.
