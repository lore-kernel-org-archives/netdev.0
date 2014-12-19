From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH net-next v3] Add support of Cavium Liquidio ethernet adapters
Date: Fri, 19 Dec 2014 23:51:15 +0100
Message-ID: <5494ABE3.5070003@gmx.de>
References: <feba8d6dd1904fc3936864ae332df6d8@CO2PR0701MB744.namprd07.prod.outlook.com> <1418959519-31681-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
	stephen Hemminger <stephen@networkplumber.org>
To: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:58228 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752438AbaLSWve (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Dec 2014 17:51:34 -0500
In-Reply-To: <1418959519-31681-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19.12.2014 04:25, Raghu Vatsavayi wrote:


> static int
> +oct_cfg_rx_intrcnt(struct lio *lio, struct ethtool_coalesce *intr_coal)
> +{

> +	}
> +
> +	spin_lock_irqsave(&cn6xxx->lock_for_droq_int_enb_reg, flags);
> +	octeon_write_csr(oct, OCT_SLI_REGNAME(oct, PKT_CNT_INT_ENB), intr);
> +	spin_unlock_irqrestore(&cn6xxx->lock_for_droq_int_enb_reg, flags);
> +
> +	return 0;

What is the reason that this is locked? If it really has to be
synchronized then there should AFAIK at least be an mmiowb() to make
sure that the write does not leak out of the lock...

Regards,
Lino
