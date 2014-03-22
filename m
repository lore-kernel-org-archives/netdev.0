From: Byungho An <bh74.an@samsung.com>
Subject: RE: [PATCH V11 2/7] net: sxgbe: add basic framework for Samsung 10Gb
 ethernet driver
Date: Sat, 22 Mar 2014 16:15:18 -0700
Message-ID: <008a01cf4624$997e1e20$cc7a5a60$@samsung.com>
References: <007f01cf4597$50abac40$f20304c0$@samsung.com>
 <532D9032.1040209@gmail.com> <008801cf4619$7b443cb0$71ccb610$@samsung.com>
 <532E07CA.5020404@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'David Miller' <davem@davemloft.net>,
	'GIRISH K S' <ks.giri@samsung.com>,
	'SIVAREDDY KALLAM' <siva.kallam@samsung.com>,
	'Vipul Chandrakant' <vipul.pandya@samsung.com>,
	'Ilho Lee' <ilho215.lee@samsung.com>
To: 'Tomasz Figa' <tomasz.figa@gmail.com>, netdev@vger.kernel.org,
	linux-samsung-soc@vger.kernel.org, devicetree@vger.kernel.org
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
In-reply-to: <532E07CA.5020404@gmail.com>
Content-language: en-us
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Tomasz Figa <tomasz.figa@gmail.com> :
> On 22.03.2014 22:55, Byungho An wrote:
> >
> > Tomasz Figa <tomasz.figa@gmail.com> :
> 
> [snip]
> 
> >>> +	if (priv->irq <= 0) {
> >>> +		dev_err(dev, "sxgbe common irq parsing failed\n");
> >>> +		sxgbe_drv_remove(ndev);
> >>> +		return -EINVAL;
> >>> +	}
> >>> +
> >>> +	/* Get the TX/RX IRQ numbers */
> >>> +	for (i = 0, chan = 0; i < SXGBE_TX_QUEUES; i++) {
> >>> +		priv->txq[i]->irq_no = irq_of_parse_and_map(node, chan++);
> >>
> >> Hmm, this call looks suspicious. The "chan" variable starts here as 0
> >> and so
> > the
> >> first call to irq_of_parse_and_map() will end up with parsing the
> >> first
> > (zeroth)
> >> entry of "interrupts" property, which would be the same as returned
> >> by platform_get_irq(..., 0) above. Maybe this was the point where the
> "loop"
> >> variable should be used?
> > OK. it will be chan instead of loop.
> > thanks I missed.
> >
> >>
> >> Anyway, why you couldn't simply use platform_get_irq() here as well?
> > I'll change platform_get_irq to irq_of_parse_and_map because latter
> > can support PCI and nonPCI
> 
> Hmm, since this function is for probing only platform devices, I don't see
how
> this code could be used for PCI. For platform devices
> platform_get_irq() is preferred.
Those things will be added after this serise.

> 
> Best regards,
> Tomasz
