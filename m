From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.20 3/5] s2io: Fixes in updating skb->truesize and
 code cleanup.
Date: Tue, 23 Jan 2007 00:46:47 -0500
Message-ID: <45B5A147.6050205@garzik.org>
References: <Pine.GSO.4.10.10701190234530.22012-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leonid.grossman@neterion.com,
	alicia.pena@neterion.com, ramkrishna.vepa@neterion.com,
	sivakumar.subramani@neterion.com, sreenivasa.honnur@neterion.com,
	sriram.rapuru@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45359 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933003AbXAWFrA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jan 2007 00:47:00 -0500
To: Ananda Raju <Ananda.Raju@neterion.com>
In-Reply-To: <Pine.GSO.4.10.10701190234530.22012-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ananda Raju wrote:
> @@ -6999,7 +7003,7 @@ s2io_init_nic(struct pci_dev *pdev, cons
>  		goto mem_alloc_failed;
>  	}
>  
> -	sp->bar0 = ioremap(pci_resource_start(pdev, 0),
> +	sp->bar0 = (caddr_t) ioremap(pci_resource_start(pdev, 0),
>  				     pci_resource_len(pdev, 0));
>  	if (!sp->bar0) {
>  		DBG_PRINT(ERR_DBG, "%s: Neterion: cannot remap io mem1\n",
> @@ -7008,7 +7012,7 @@ s2io_init_nic(struct pci_dev *pdev, cons
>  		goto bar0_remap_failed;
>  	}
>  
> -	sp->bar1 = ioremap(pci_resource_start(pdev, 2),
> +	sp->bar1 = (caddr_t) ioremap(pci_resource_start(pdev, 2),
>  				     pci_resource_len(pdev, 2));
>  	if (!sp->bar1) {
>  		DBG_PRINT(ERR_DBG, "%s: Neterion: cannot remap io mem2\n",

adds pointless casts.

further, caddr_t type should /never/ be used.

Linux kernel uses void*, from which you may assign to/from freely, 
without casting.




> @@ -7645,6 +7649,7 @@ static void lro_append_pkt(nic_t *sp, lr
>  		lro->last_frag->next = skb;
>  	else
>  		skb_shinfo(first)->frag_list = skb;
> +	first->truesize += skb->truesize;//updating skb->truesize
>  	lro->last_frag = skb;
>  	sp->mac_control.stats_info->sw_stat.clubbed_frms_cnt++;
>  	return;

pointless comment (and C++ too, which is discouraged)

