From: Chris Poon <dev-null@telus.net>
Subject: Re: [Bugme-new] [Bug 9270] New: sunhme requires lower MTU to handle 802.1q frames
Date: Thu,  1 Nov 2007 13:52:13 -0700
Message-ID: <1193950333.472a3c7d30c3d@webmail.telus.net>
References: <bug-9270-10286@http.bugzilla.kernel.org/> <20071031154301.3cc0fbb9.akpm@linux-foundation.org> <20071031.163557.73546666.davem@davemloft.net> <20071101121239.d0e67bd3.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, jeff@garzik.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound04.telus.net ([199.185.220.223]:53670 "EHLO
	outbound04.telus.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759807AbXKAWsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 18:48:24 -0400
In-Reply-To: <20071101121239.d0e67bd3.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Forgot to add that only changing BMAC_TXMAX & BMAC_RXMAX wouldn't work
for me, until I changed 2 skb_put as well (which is in the patch that
I submitted in bugzilla). Dug up some really old threads on the net
and found out that this was reported before

Quoting Andrew Morton <akpm@linux-foundation.org>:

> On Wed, 31 Oct 2007 16:35:57 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Andrew Morton <akpm@linux-foundation.org>
> > Date: Wed, 31 Oct 2007 15:43:01 -0700
> > 
> > > > sunhme requires lower MTU to handle 802.1q frames - even though the
> PCI
> > > > driver supported VLAN tagging, you cannot do full MTU @ 1500 because
> the
> > > > driver doesn't set the card to transfer more the extra bytes for a
> 802.1q
> > > > frame at 1500 MTU.
> > 
> > It supports VLAN tagging by accident, the NETIF_F_VLAN_CHALLENGED
> > flag should be set both in the PCI and non-PCI cases.
> > 
> > Jeff, please apply, thanks:
> > 
> > [SUNHME]: Fix missing NETIF_F_VLAN_CHALLENGED on PCI happy meals.
> > 
> > No HME parts can do VLANs correctly.
> > 
> > Signed-off-by: David S. Miller <davem@davemloft.net>
> > 
> > diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
> > index 120c8af..c20a3bd 100644
> > --- a/drivers/net/sunhme.c
> > +++ b/drivers/net/sunhme.c
> > @@ -3143,8 +3143,8 @@ static int __devinit happy_meal_pci_probe(struct
> pci_dev *pdev,
> >  	dev->irq = pdev->irq;
> >  	dev->dma = 0;
> >  
> > -	/* Happy Meal can do it all... */
> > -	dev->features |= NETIF_F_SG | NETIF_F_HW_CSUM;
> > +	/* Happy Meal can do it all... except VLAN. */
> > +	dev->features |= NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_VLAN_CHALLENGED;
> >  
> >  #if defined(CONFIG_SBUS) && defined(CONFIG_PCI)
> >  	/* Hook up PCI register/dma accessors. */
> 
> I forgot to add my standard "please reply via emailed reply-to-all, not via
> the bugzilla web interface", so Chris has gone and attempted to communicate
> with us via the bugzilla UI (sigh).
> 
> He asked
> 
> "Even though it appears to work after I bumped the BMAC_TXMAX / BMAC_RXMAX?"
> 
> 
> 




