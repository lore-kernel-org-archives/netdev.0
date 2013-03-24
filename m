From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Atheros Communications Inc. AR8121/AR8113/AR8114 Gigabit or Fast Ethernet (rev b0) 1.0.0.7 md5/sha1 corrupted using NFS and samba (updated) Version 2
Date: Sun, 24 Mar 2013 05:37:38 +0100
Message-ID: <20130324043738.GD17948@order.stressinduktion.org>
References: <20130323021008.GC939@order.stressinduktion.org> <514D3581.4040001@gmail.com> <20130323150655.GA10779@order.stressinduktion.org> <69jo698argv8@mids.svenhartge.de> <20130324012625.GA17948@order.stressinduktion.org> <89joa2largv8@mids.svenhartge.de> <20130324014125.GB17948@order.stressinduktion.org> <157393863283F442885425D2C4542856489E7C79@nasanexd02f.na.qualcomm.com> <20130324034037.GC17948@order.stressinduktion.org> <157393863283F442885425D2C4542856489E7CA8@nasanexd02f.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Sven Hartge <sven@svenhartge.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Huang, Xiong" <xiong@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54413 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751225Ab3CXEhj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 00:37:39 -0400
Content-Disposition: inline
In-Reply-To: <157393863283F442885425D2C4542856489E7CA8@nasanexd02f.na.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 24, 2013 at 04:21:27AM +0000, Huang, Xiong wrote:
> I know that from some version of chips, there is a DMA bug that can't be fixed by software, and this bug could be detected by checking Sequence number, and do MAC reset.
> Besides, the chip wrongly indicate rx-checksum for IP-fragment packet, I checked windows code, it seems a little bit different with linux code:

Thanks, I will have a closer look at it tomorrow.

> 
> 	if (((pkt_flags & RRS_IS_IPV4) && ((pkt_flags & RRS_IS_TCP) || (pkt_flags & RRS_IS_UDP))) {
> 		if (pkt_flags & RRS_IS_802_3)
> 			head_len += 8;
> 		iph = (struct iphdr *) (packet + head_len);
> 		if ((iph->frag_off != 0 || (pkt_flags & RRS_IS_IP_FRAG))  && !(pkt_flags & RRS_IS_IP_DF))
> 			goto hw_xsum;			
> 	}
> 	if (!(err_flags & (RRS_ERR_IP_CSUM | RRS_ERR_L4_CSUM))) {
> 		skb->ip_summed = CHECKSUM_UNNECESSARY;
> 		return;
> 	}

Btw the captured corrupted packets are ordinary non-fragmented TCP IPv4
packets. But perhaps these flags are dual-use?

Thanks for looking into it,

  Hannes
