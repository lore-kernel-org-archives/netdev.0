From: Manoil Claudiu <claudiu.manoil@freescale.com>
Subject: RE: [PATCH net-next 2/4] gianfar: Fix and cleanup rxbd status
 handling
Date: Mon, 13 Jul 2015 07:43:59 +0000
Message-ID: <DM2PR03MB4142B3022ACA285C0DC261D9C9C0@DM2PR03MB414.namprd03.prod.outlook.com>
References: <1436459084-14103-1-git-send-email-claudiu.manoil@freescale.com>
	<1436459084-14103-3-git-send-email-claudiu.manoil@freescale.com>
 <20150710.182516.1107515769111345392.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0114.outbound.protection.outlook.com ([65.55.169.114]:28272
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751608AbbGMHoC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 03:44:02 -0400
In-Reply-To: <20150710.182516.1107515769111345392.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Saturday, July 11, 2015 4:25 AM
> To: Manoil Claudiu-B08782
> Cc: netdev@vger.kernel.org
> Subject: Re: [PATCH net-next 2/4] gianfar: Fix and cleanup rxbd status
> handling
> 
> From: Claudiu Manoil <claudiu.manoil@freescale.com>
> Date: Thu, 9 Jul 2015 19:24:42 +0300
> 
> > @@ -2921,6 +2921,7 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q
> *rx_queue, int rx_work_limit)
> >  	i = rx_queue->next_to_clean;
> >
> >  	while (rx_work_limit--) {
> > +		unsigned long lstatus;
> >
> >  		if (cleaned_cnt >= GFAR_RX_BUFF_ALLOC) {
> >  			gfar_alloc_rx_buffs(rx_queue, cleaned_cnt);
> > @@ -2928,7 +2929,8 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q
> *rx_queue, int rx_work_limit)
> >  		}
> >
> >  		bdp = &rx_queue->rx_bd_base[i];
> > -		if (be16_to_cpu(bdp->status) & RXBD_EMPTY)
> > +		lstatus = be32_to_cpu(bdp->lstatus);
> > +		if (lstatus & BD_LFLAG(RXBD_EMPTY))
> >  			break;
> >
> >  		/* order rx buffer descriptor reads */
> 
> "lstatus" is not an "unsigned long", it's a "u32".
> 
> Don't use ambiguous types for objects with exact known sizes.

I agree, will send v2.  Maybe I thought it would be safe enough
since old "status" was "unsigned short", but I agree about dispelling
the ambiguity by using u32.  Thanks.

Claudiu
