From: "Chickles, Derek" <Derek.Chickles@caviumnetworks.com>
Subject: RE: [PATCH net-next v3] Add support of Cavium Liquidio ethernet
 adapters
Date: Fri, 19 Dec 2014 22:20:34 +0000
Message-ID: <BY2PR07MB486A98FB6C4520C7DEDA564FE6B0@BY2PR07MB486.namprd07.prod.outlook.com>
References: <feba8d6dd1904fc3936864ae332df6d8@CO2PR0701MB744.namprd07.prod.outlook.com>
 <1418959519-31681-1-git-send-email-rvatsavayi@caviumnetworks.com>
 <5494A0DD.1010304@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Burla, Satananda" <Satananda.Burla@caviumnetworks.com>,
	"Manlunas, Felix" <Felix.Manlunas@caviumnetworks.com>,
	"Vatsavayi, Raghu" <Raghu.Vatsavayi@caviumnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>,
	"Vatsavayi, Raghu" <Raghu.Vatsavayi@caviumnetworks.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0072.outbound.protection.outlook.com ([65.55.169.72]:47969
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752087AbaLSWfi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 17:35:38 -0500
In-Reply-To: <5494A0DD.1010304@gmx.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On 19.12.2014 04:25, Raghu Vatsavayi wrote:
> > +static void cn6xxx_disable_interrupt(void *chip)
> > +{
> > +	struct octeon_cn6xxx *cn6xxx = (struct octeon_cn6xxx *)chip;
> > +
> > +	/* Disable Interrupts */
> > +	writeq(0, cn6xxx->intr_enb_reg64);
> > +}
> > +
> 
> This could also be a good candidate for forced write posting. The code
> assumes that interrupts are actually deactivated after that.
> 
> Regards,
> Lino
> 
> 
Good catch. We'll examine all the writeq and OCTEON_PCI_WIN_WRITE
calls to make sure there aren't any other critical posted write scenarios that
we've missed.
