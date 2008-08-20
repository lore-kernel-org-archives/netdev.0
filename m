From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 MTU greater than 1500 causes corruption for other
	controllers
Date: Wed, 20 Aug 2008 23:43:50 +0200
Message-ID: <20080820214350.GA18747@electric-eye.fr.zoreil.com>
References: <20080820170951.GA1771@tophat.atxconsulting.com> <Pine.LNX.4.64.0808202053510.24321@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=unknown-8bit
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Timothy J Fontaine <tjfontaine@atxconsulting.com>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Ilpo =?unknown-8bit?B?SsOkcnZpbmVu?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:54017 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752856AbYHTVoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 17:44:04 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0808202053510.24321@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi> :
[...]
> Hmm, there was no explanation why the tp->rx_buf_sz to pkt_size chang=
e
> was made in that commit (I have no idea whether those sizes have to m=
atch=20
> to other places that use tp->rx_buf_sz)...

Because there is no need to sync data that has not been used ?

Timothy, could you check if the patch below does the job too ? It shoul=
d
fix at least one pci_map / pci_unmap unbalance.

@@ -2789,10 +2789,10 @@ static int rtl8169_rx_interrupt(struct net_devi=
ce *dev,
=20
 			if (rtl8169_try_rx_copy(&skb, tp, pkt_size, addr)) {
 				pci_dma_sync_single_for_device(pdev, addr,
 					pkt_size, PCI_DMA_FROMDEVICE);
 				rtl8169_mark_to_asic(desc, tp->rx_buf_sz);
 			} else {
-				pci_unmap_single(pdev, addr, pkt_size,
+				pci_unmap_single(pdev, addr, tp->rx_buf_sz,
 						 PCI_DMA_FROMDEVICE);
 				tp->Rx_skbuff[entry] =3D NULL;
 			}

--=20
Ueimor
