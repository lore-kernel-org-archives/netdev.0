From: Ondrej Zary <linux@rainbow-software.org>
Subject: Re: [PATCH 1/3] dl2k: Handle memory allocation errors in alloc_list
Date: Wed, 18 Nov 2015 09:10:40 +0100
Message-ID: <201511180910.40728.linux@rainbow-software.org>
References: <1447781298-19785-1-git-send-email-linux@rainbow-software.org> <20151117225403.GA3362@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151117225403.GA3362@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 17 November 2015, Francois Romieu wrote:
> Ondrej Zary <linux@rainbow-software.org> :
> > If memory allocation fails in alloc_list(), free the already allocated
> > memory and return -ENODEV. In rio_open(), call alloc_list() first and
> > abort if it fails. Move HW access (set RFDListPtr) out ot alloc_list().
> >
> > Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
>
> ENODEV vs ENOMEM aside, it's ok with me.

Will fix the description in v2.

> The driver may avoid depleting the receive ring when
> netdev_alloc_skb_ip_align fails in receive_packet (drop and increase
> stats->rx_dropped).
>
> Then you may replace the pci_* dma helpers with the plain dma_* ones (they
> can fail).
>
> And perform a plain napi conversion.

NAPI is on the todo list. Thanks for suggestions.

-- 
Ondrej Zary
