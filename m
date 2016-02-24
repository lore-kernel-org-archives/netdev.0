From: Yangbo Lu <yangbo.lu@nxp.com>
Subject: RE: [PATCH 3/3] gianfar: fix endianness for hardware timestamp
Date: Wed, 24 Feb 2016 09:24:04 +0000
Message-ID: <HE1PR04MB0889C90C284F8C3B0F04DDA1F8A50@HE1PR04MB0889.eurprd04.prod.outlook.com>
References: <1456123773-1016-1-git-send-email-yangbo.lu@nxp.com>
 <1456123773-1016-4-git-send-email-yangbo.lu@nxp.com>
 <20160222084801.GC2138@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0086.outbound.protection.outlook.com ([157.55.234.86]:13856
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751270AbcBXJjf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 04:39:35 -0500
In-Reply-To: <20160222084801.GC2138@netboy>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Monday, February 22, 2016 4:48 PM
> To: Yangbo Lu
> Cc: netdev@vger.kernel.org; Claudiu Manoil
> Subject: Re: [PATCH 3/3] gianfar: fix endianness for hardware timestamp
> 
> On Mon, Feb 22, 2016 at 02:49:33PM +0800, Yangbo Lu wrote:
> > @@ -2708,6 +2708,7 @@ static void gfar_clean_tx_ring(struct
> gfar_priv_tx_q *tx_queue)
> >  			struct skb_shared_hwtstamps shhwtstamps;
> >  			u64 *ns = (u64 *)(((uintptr_t)skb->data + 0x10) &
> >  					  ~0x7UL);
> > +			*ns = be64_to_cpu(*ns);
> >
> >  			memset(&shhwtstamps, 0, sizeof(shhwtstamps));
> >  			shhwtstamps.hwtstamp = ns_to_ktime(*ns);
> 
> There is no point in modifying the buffer data in place.
> 
> Instead, do this:
> 
> 			memset(&shhwtstamps, 0, sizeof(shhwtstamps));
> 			shhwtstamps.hwtstamp = ns_to_ktime(be64_to_cpu(*ns));
> 
> or this:
> 
> 			u64 ns, *ptr = (u64 *)(((uintptr_t)skb->data + 0x10) &
> 					       ~0x7UL);
> 			ns = be64_to_cpu(*ptr);
> 
> 			memset(&shhwtstamps, 0, sizeof(shhwtstamps));
> 			shhwtstamps.hwtstamp = ns_to_ktime(ns);
> 

[Lu Yangbo-B47093] I will modify codes according your suggestion.
Thank you so much!
 
> > @@ -3037,6 +3038,7 @@ static void gfar_process_frame(struct net_device
> *ndev, struct sk_buff *skb)
> >  	if (priv->hwts_rx_en) {
> >  		struct skb_shared_hwtstamps *shhwtstamps = skb_hwtstamps(skb);
> >  		u64 *ns = (u64 *) skb->data;
> > +		*ns = be64_to_cpu(*ns);
> >
> >  		memset(shhwtstamps, 0, sizeof(*shhwtstamps));
> >  		shhwtstamps->hwtstamp = ns_to_ktime(*ns);
> 
> Same here.
> 
> Thanks,
> Richard
