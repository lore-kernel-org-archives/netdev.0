From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] sky2:  receive dma mapping error handling
Date: Tue, 02 Feb 2010 23:44:37 +0100
Message-ID: <87aavrdzqi.fsf@basil.nowhere.org>
References: <4B60707F.1000608@majjas.com> <20100127095614.14313677@nehalam>
	<4B608128.7090607@majjas.com> <4B6089C7.4010803@majjas.com>
	<4B61ADF1.7060705@majjas.com> <4B61BEA4.1030905@majjas.com>
	<20100128090835.0d93e53a@nehalam> <4B61DB79.4080703@majjas.com>
	<20100128223447.GC3109@del.dom.local> <4B621316.8070308@majjas.com>
	<20100128225621.GD3109@del.dom.local> <4B6216B9.1010802@majjas.com>
	<20100128153643.0fca3c51@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Breuer <mbreuer@majjas.com>,
	Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>,
	Don Fry <pcnet32@verizon.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:35878 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757113Ab0BBWom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 17:44:42 -0500
In-Reply-To: <20100128153643.0fca3c51@nehalam> (Stephen Hemminger's message of "Thu, 28 Jan 2010 15:36:43 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@linux-foundation.org> writes:

> -	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
> -		re->frag_addr[i] = pci_map_page(pdev,
> +
> +map_page_error:
> +	while (--i >= 0) {
> +		pci_unmap_page(pdev, re->frag_addr[i],
> +			       skb_shinfo(skb)->frags[i].size,
> +			       PCI_DMA_FROMDEVICE);
> +	}
> +
> +	pci_unmap_single(pdev, re->data_addr, pci_unmap_len(re, data_size),
> +			 PCI_DMA_FROMDEVICE);

Better add a helper somewhere to do this, doesn't make sense
to duplicate this in all drivers (lots of drivers have similar
problems)

I remember looking at this some time ago but for some reason
the patches never made it out.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
