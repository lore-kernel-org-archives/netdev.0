From: Andi Kleen <ak@muc.de>
Subject: Re: [PATCH] NUMA aware allocation of transmit and receive buffers
 for e1000
Date: Wed, 18 May 2005 04:05:25 +0200
Message-ID: <m1sm0l5lwa.fsf@muc.de>
References: <Pine.LNX.4.62.0505171854490.20408@graphe.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Lameter <christoph@graphe.net>
In-Reply-To: <Pine.LNX.4.62.0505171854490.20408@graphe.net> (Christoph
 Lameter's message of "Tue, 17 May 2005 18:56:06 -0700 (PDT)")
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Christoph Lameter <christoph@graphe.net> writes:

> @@ -513,6 +513,7 @@ e1000_probe(struct pci_dev *pdev,
>  	netdev->mem_start = mmio_start;
>  	netdev->mem_end = mmio_start + mmio_len;
>  	netdev->base_addr = adapter->hw.io_base;
> +	netdev->node = pcibus_to_node(pdev->bus);

I think it would be better to define a common helper (pdev_kmalloc ?)
for this that just takes the pdev and that can be defined to a nop for
!CONFIG_NUMA Kernels.  This would avoid the bloat of the ->node
argument on non numa kernels and is a cleaner interface
too. pcibus_to_node() is just an array lookup and should be cheap
enough to redo.

-Andi
