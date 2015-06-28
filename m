From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net] dsa: fix promiscuity leak on slave dev open error
Date: Sun, 28 Jun 2015 19:09:53 +0200
Message-ID: <20150628170953.GW9469@lunn.ch>
References: <1435240213-15179-1-git-send-email-giladb@ezchip.com>
 <20150626150401.GH9469@lunn.ch>
 <CAOtvUMd0iFYDhFQT6CFvYvvTjGCNYRX2i2vqJaXf3m=+2z=_jw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gilad Ben-Yossef <giladb@ezchip.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Scott Feldman <sfeldma@gmail.com>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58853 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752460AbbF1RQA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Jun 2015 13:16:00 -0400
Content-Disposition: inline
In-Reply-To: <CAOtvUMd0iFYDhFQT6CFvYvvTjGCNYRX2i2vqJaXf3m=+2z=_jw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> It has occurred to me that dev_set_promiscuity() and its brethren
> dev_set_allmulti() may not be the best of interfaces:
> 
> - On cursory inspection of code using these function their name
> implies the value of the relevant counter is set to the value passed
> as parameter, not incremented by it.
> - No caller I've managed to spot passes anything but -1 or 1
> 
> It seems an interface of
> 
> int dev_set_promiscuity(struct net_device *dev, bool on);
> 
> int dev_set_allmulti(struct net_device *dev, bool on);

on suggests it is an absolute, when in fact you are passing an
increment, so i don't think it is much of an improvement.

Adding #define, PROMISC_INC and PROMISC_DEC might be clearer, and
since this is not a fast path, you could consider parameter
validation. Or dev_get_promiscuity(), det_put_promiscuity().
 
> would be as functional (for current users), more readable and less
> error prone but I am not sure such a tiny problem (if you can call
> this a problem) is worth the churn...

There was only one instance of it wrong, so it is not a very big
problem. I would say it is not worth the churn.

	 Andrew
