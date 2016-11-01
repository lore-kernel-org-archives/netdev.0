From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH v3 net-next] lan78xx: Use irq_domain for phy interrupt
 from USB Int. EP
Date: Tue, 1 Nov 2016 17:07:17 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D4095D227@CHN-SV-EXMX02.mchp-main.com>
References: <9235D6609DB808459E95D78E17F2E43D4095CACB@CHN-SV-EXMX02.mchp-main.com>
 <20161101.120322.716031785792281107.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <f.fainelli@gmail.com>, <andrew@lunn.ch>,
        <UNGLinuxDriver@microchip.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp03.microchip.com ([198.175.253.49]:45461 "EHLO
        email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753234AbcKARHh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 13:07:37 -0400
In-Reply-To: <20161101.120322.716031785792281107.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > @@ -2668,6 +2821,13 @@ static int lan78xx_bind(struct lan78xx_net *dev,
> struct usb_interface *intf)
> >
> >  	dev->net->hw_features = dev->net->features;
> >
> > +	ret = lan78xx_setup_irq_domain(dev);
> > +	if (ret < 0) {
> > +		netdev_warn(dev->net,
> > +			    "lan78xx_setup_irq_domain() failed : %d", ret);
> > +		return ret;
> > +	}
> > +
> 
> This error path leaks the memory allocated at the beginning of this function.
> 
> That would normally be freed up by lan78xx_unbind() but the caller will not
> invoke that if lan78xx_bind() fails so you have to take care of the kfree
> here.

David,
Thanks for review and finding.
Will fix and post new patch.

- Woojung
