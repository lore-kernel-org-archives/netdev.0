From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [patch 2.6.11-rc3 5/5] r8169: synchronization and balancing when the device is closed
Date: Mon, 14 Feb 2005 20:31:06 +0100
Message-ID: <20050214193106.GA14409@electric-eye.fr.zoreil.com>
References: <20050211233918.GB8792@electric-eye.fr.zoreil.com> <20050211234403.GC13644@electric-eye.fr.zoreil.com> <20050211234522.GD13644@electric-eye.fr.zoreil.com> <200502141116.54441.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, akpm@osdl.org, netdev@oss.sgi.com
To: Jon Mason <jdmason@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <200502141116.54441.jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jon Mason <jdmason@us.ibm.com> :
> [...]
> > @@ -2399,6 +2398,8 @@ static int rtl8169_close(struct net_devi
> >  
> >   free_irq(dev->irq, dev);
> >  
> > + netif_poll_enable(dev);
> > +
> >   pci_free_consistent(pdev, R8169_RX_RING_BYTES, tp->RxDescArray,
> >         tp->RxPhyAddr);
> >   pci_free_consistent(pdev, R8169_TX_RING_BYTES, tp->TxDescArray,
> > 
> > _
> 
> Dumb question....Why is this needed?  dev_close has already checked for the 

dev_open() after dev_close(): netif_rx_schedule_prep() always fails in
rtl8169_interrupt() and the device can not be scheduled for poll. Sucky.

So, if someone wants to push it before 2.6.11 goes out...

-- 
Ueimor
