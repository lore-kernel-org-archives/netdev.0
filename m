From: "Chickles, Derek" <Derek.Chickles@caviumnetworks.com>
Subject: RE: [PATCH net-next v3] Add support of Cavium Liquidio ethernet
 adapters
Date: Sat, 20 Dec 2014 00:47:20 +0000
Message-ID: <BY2PR07MB486D1ABE6E149FC2FE06217FE680@BY2PR07MB486.namprd07.prod.outlook.com>
References: <feba8d6dd1904fc3936864ae332df6d8@CO2PR0701MB744.namprd07.prod.outlook.com>
 <1418959519-31681-1-git-send-email-rvatsavayi@caviumnetworks.com>
 <5494ABE3.5070003@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Burla, Satananda" <Satananda.Burla@caviumnetworks.com>,
	"Manlunas, Felix" <Felix.Manlunas@caviumnetworks.com>,
	"Vatsavayi, Raghu" <Raghu.Vatsavayi@caviumnetworks.com>,
	stephen Hemminger <stephen@networkplumber.org>
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>,
	"Vatsavayi, Raghu" <Raghu.Vatsavayi@caviumnetworks.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0056.outbound.protection.outlook.com ([65.55.169.56]:56091
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751842AbaLTArY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 19:47:24 -0500
In-Reply-To: <5494ABE3.5070003@gmx.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > static int
> > +oct_cfg_rx_intrcnt(struct lio *lio, struct ethtool_coalesce *intr_coal)
> > +{
> 
> > +	}
> > +
> > +	spin_lock_irqsave(&cn6xxx->lock_for_droq_int_enb_reg, flags);
> > +	octeon_write_csr(oct, OCT_SLI_REGNAME(oct, PKT_CNT_INT_ENB),
> intr);
> > +	spin_unlock_irqrestore(&cn6xxx->lock_for_droq_int_enb_reg,
> flags);
> > +
> > +	return 0;
> 
> What is the reason that this is locked? If it really has to be
> synchronized then there should AFAIK at least be an mmiowb() to make
> sure that the write does not leak out of the lock...
> 
> Regards,
> Lino
> 

Yes, we need this locked because the interrupt handler accesses this as well,
But you are right we need the mmiowb().

Thanks,
Derek
