From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: [patch 2.6.11-rc3 5/5] r8169: synchronization and balancing when the device is closed
Date: Mon, 14 Feb 2005 11:16:54 -0600
Message-ID: <200502141116.54441.jdmason@us.ibm.com>
References: <20050211233918.GB8792@electric-eye.fr.zoreil.com> <20050211234403.GC13644@electric-eye.fr.zoreil.com> <20050211234522.GD13644@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, akpm@osdl.org, netdev@oss.sgi.com
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050211234522.GD13644@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[...]
> @@ -2399,6 +2398,8 @@ static int rtl8169_close(struct net_devi
>  
>   free_irq(dev->irq, dev);
>  
> + netif_poll_enable(dev);
> +
>   pci_free_consistent(pdev, R8169_RX_RING_BYTES, tp->RxDescArray,
>         tp->RxPhyAddr);
>   pci_free_consistent(pdev, R8169_TX_RING_BYTES, tp->TxDescArray,
> 
> _

Dumb question....Why is this needed?  dev_close has already checked for the 
bit before it calls the rtl8169_close routine (and it was already ripped out 
by netif_poll_disable in rtl8169_down).  

-- 
Jon Mason
jdmason@us.ibm.com
