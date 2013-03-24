From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Atheros Communications Inc. AR8121/AR8113/AR8114 Gigabit or Fast Ethernet (rev b0) 1.0.0.7 md5/sha1 corrupted using NFS and samba (updated) Version 2
Date: Sun, 24 Mar 2013 06:13:25 +0100
Message-ID: <20130324051325.GE17948@order.stressinduktion.org>
References: <20130323150655.GA10779@order.stressinduktion.org> <69jo698argv8@mids.svenhartge.de> <20130324012625.GA17948@order.stressinduktion.org> <89joa2largv8@mids.svenhartge.de> <20130324014125.GB17948@order.stressinduktion.org> <157393863283F442885425D2C4542856489E7C79@nasanexd02f.na.qualcomm.com> <20130324034037.GC17948@order.stressinduktion.org> <157393863283F442885425D2C4542856489E7CA8@nasanexd02f.na.qualcomm.com> <20130324043738.GD17948@order.stressinduktion.org> <157393863283F442885425D2C4542856489E7CCD@nasanexd02f.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Sven Hartge <sven@svenhartge.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Huang, Xiong" <xiong@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54431 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752345Ab3CXFN0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 01:13:26 -0400
Content-Disposition: inline
In-Reply-To: <157393863283F442885425D2C4542856489E7CCD@nasanexd02f.na.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 24, 2013 at 04:54:46AM +0000, Huang, Xiong wrote:
> 
> > 
> > >
> > > 	if (((pkt_flags & RRS_IS_IPV4) && ((pkt_flags & RRS_IS_TCP) ||
> > (pkt_flags & RRS_IS_UDP))) {
> > > 		if (pkt_flags & RRS_IS_802_3)
> > > 			head_len += 8;
> > > 		iph = (struct iphdr *) (packet + head_len);
> > > 		if ((iph->frag_off != 0 || (pkt_flags & RRS_IS_IP_FRAG))
> > && !(pkt_flags & RRS_IS_IP_DF))
> > > 			goto hw_xsum;
> > > 	}
> > > 	if (!(err_flags & (RRS_ERR_IP_CSUM | RRS_ERR_L4_CSUM))) {
> > > 		skb->ip_summed = CHECKSUM_UNNECESSARY;
> > > 		return;
> > > 	}
> > 
> > Btw the captured corrupted packets are ordinary non-fragmented TCP IPv4
> > packets. But perhaps these flags are dual-use?
> > 
> Not dual-use.  You could check  flags for corrupted packets and compare it with good packet.
> Your corrupted packet is just TCP checksum error ?

I'll try it.

The caputered packets show that a 16 byte segment overwrites later data in the
same packet, sometimes even multiple contiguous 16 byte segments.

The corrupted packets look like this:

...ABC....DBBEF..

Each character represents a 16 byte region, the dots are dont-care
placeholders. The BB-region is overwritten by the data of the first
B-region.

Thanks,

  Hannes
