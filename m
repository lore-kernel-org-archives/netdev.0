From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 8/13] r8169: Tx performance tweak
Date: Mon, 30 Jun 2008 11:53:59 +0100
Message-ID: <20080630105357.GH4050@solarflare.com>
References: <20080629143817.GA1540@electric-eye.fr.zoreil.com> <20080629144526.GI1540@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeff@garzik.org, akpm@linux-foundation.org,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Mario Limonciello <mario_limonciello@dell.com>,
	Kasper Sandberg <lkml@metanurb.dk>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.mbr-roch.zen.net.uk ([212.23.3.142]:41558 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752685AbYF3KyU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2008 06:54:20 -0400
Content-Disposition: inline
In-Reply-To: <20080629144526.GI1540@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu wrote:
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Edward Hsu <edward_hsu@realtek.com.tw>
> ---
>  drivers/net/r8169.c |   10 +++++-----
>  1 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index c2861a4..46bdcb9 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -2156,19 +2156,19 @@ static void rtl_hw_start_8169(struct net_device *dev)
>  	RTL_W16(IntrMask, tp->intr_event);
>  }
>  
> -static void rtl8168_tx_performance_tweak(struct pci_dev *pdev, unsigned int reg
> -)
> +static void rtl8168_tx_performance_tweak(struct pci_dev *pdev,
> +					 unsigned int reg, u8 force)
>  {
>  	u8 ctl;
>  
>  	pci_read_config_byte(pdev, reg, &ctl);
> -	ctl = (ctl & ~0x70) | 0x50;
> +	ctl = (ctl & ~0x70) | force;
>  	pci_write_config_byte(pdev, reg, ctl);
[...]

This would be a lot more understandable if you used pci_find_capability()
and the named constants from <linux/pci_regs.h>:

#define PCI_EXP_DEVCTL          8       /* Device Control */
#define  PCI_EXP_DEVCTL_NOSNOOP_EN 0x0800  /* Enable No Snoop */
#define  PCI_EXP_DEVCTL_READRQ  0x7000  /* Max_Read_Request_Size */

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
