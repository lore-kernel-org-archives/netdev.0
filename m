From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9270] New: sunhme requires lower MTU to handle
 802.1q frames
Date: Thu, 1 Nov 2007 12:12:39 -0700
Message-ID: <20071101121239.d0e67bd3.akpm@linux-foundation.org>
References: <bug-9270-10286@http.bugzilla.kernel.org/>
	<20071031154301.3cc0fbb9.akpm@linux-foundation.org>
	<20071031.163557.73546666.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	dev-null@telus.net, jeff@garzik.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:59513 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758035AbXKATNQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 15:13:16 -0400
In-Reply-To: <20071031.163557.73546666.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 31 Oct 2007 16:35:57 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Wed, 31 Oct 2007 15:43:01 -0700
> 
> > > sunhme requires lower MTU to handle 802.1q frames - even though the PCI
> > > driver supported VLAN tagging, you cannot do full MTU @ 1500 because the
> > > driver doesn't set the card to transfer more the extra bytes for a 802.1q
> > > frame at 1500 MTU.
> 
> It supports VLAN tagging by accident, the NETIF_F_VLAN_CHALLENGED
> flag should be set both in the PCI and non-PCI cases.
> 
> Jeff, please apply, thanks:
> 
> [SUNHME]: Fix missing NETIF_F_VLAN_CHALLENGED on PCI happy meals.
> 
> No HME parts can do VLANs correctly.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
> index 120c8af..c20a3bd 100644
> --- a/drivers/net/sunhme.c
> +++ b/drivers/net/sunhme.c
> @@ -3143,8 +3143,8 @@ static int __devinit happy_meal_pci_probe(struct pci_dev *pdev,
>  	dev->irq = pdev->irq;
>  	dev->dma = 0;
>  
> -	/* Happy Meal can do it all... */
> -	dev->features |= NETIF_F_SG | NETIF_F_HW_CSUM;
> +	/* Happy Meal can do it all... except VLAN. */
> +	dev->features |= NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_VLAN_CHALLENGED;
>  
>  #if defined(CONFIG_SBUS) && defined(CONFIG_PCI)
>  	/* Hook up PCI register/dma accessors. */

I forgot to add my standard "please reply via emailed reply-to-all, not via
the bugzilla web interface", so Chris has gone and attempted to communicate
with us via the bugzilla UI (sigh).

He asked

"Even though it appears to work after I bumped the BMAC_TXMAX / BMAC_RXMAX?"


