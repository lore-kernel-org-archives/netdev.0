From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/3] dl2k: Handle memory allocation errors in alloc_list
Date: Tue, 17 Nov 2015 23:54:03 +0100
Message-ID: <20151117225403.GA3362@electric-eye.fr.zoreil.com>
References: <1447781298-19785-1-git-send-email-linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1447781298-19785-1-git-send-email-linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ondrej Zary <linux@rainbow-software.org> :
> If memory allocation fails in alloc_list(), free the already allocated
> memory and return -ENODEV. In rio_open(), call alloc_list() first and
> abort if it fails. Move HW access (set RFDListPtr) out ot alloc_list().
> 
> Signed-off-by: Ondrej Zary <linux@rainbow-software.org>

ENODEV vs ENOMEM aside, it's ok with me.

The driver may avoid depleting the receive ring when netdev_alloc_skb_ip_align
fails in receive_packet (drop and increase stats->rx_dropped).

Then you may replace the pci_* dma helpers with the plain dma_* ones (they
can fail).

And perform a plain napi conversion.

-- 
Ueimor
