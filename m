From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: [PATCH] PCI: MSI: Remove unsafe and unnecessary hardware access
Date: Fri, 2 Jul 2010 16:16:34 -0700
Message-ID: <20100702161634.2529ad4e@virtuousgeek.org>
References: <1276564403.19104.28.camel@HP1>
	<1276802196.2083.12.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>, Matthew Wilcox <matthew@wil.cx>,
	linux-pci@vger.kernel.org, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1276802196.2083.12.camel@achroite.uk.solarflarecom.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 17 Jun 2010 20:16:36 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> During suspend on an SMP system, {read,write}_msi_msg_desc() may be
> called to mask and unmask interrupts on a device that is already in a
> reduced power state.  At this point memory-mapped registers including
> MSI-X tables are not accessible, and config space may not be fully
> functional either.
> 
> While a device is in a reduced power state its interrupts are
> effectively masked and its MSI(-X) state will be restored when it is
> brought back to D0.  Therefore these functions can simply read and
> write msi_desc::msg for devices not in D0.
> 
> Further, read_msi_msg_desc() should only ever be used to update a
> previously written message, so it can always read msi_desc::msg
> and never needs to touch the hardware.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied to my linux-next branch, thanks.

Matthew, let me know if you have an issue with this.

Thanks,
-- 
Jesse Barnes, Intel Open Source Technology Center
