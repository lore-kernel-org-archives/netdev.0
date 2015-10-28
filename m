From: Neil Armstrong <narmstrong@baylibre.com>
Subject: Re: [PATCH 6/6] net: phy: Stop 'phy-state-machine' and 'phy_change'
 work on remove
Date: Wed, 28 Oct 2015 14:54:35 +0100
Message-ID: <5630D39B.2090306@baylibre.com>
References: <562F8EF1.5090504@baylibre.com> <562F9AEE.5050708@gmail.com>
 <CAJ03sU_+nkvN1ZeqvWx56B7cb9GDCbpTFn6gJp2OmW-CKi7QFA@mail.gmail.com>
 <562F9F06.7040402@gmail.com> <20151027212045.GC2307@lunn.ch>
 <CAJ03sU9Uw9SLXGpH9wqm+GWJtFZvcSuW=YCTZseSanpNeF_+Sw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Frode Isaksen <fisaksen@baylibre.com>, Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJ03sU9Uw9SLXGpH9wqm+GWJtFZvcSuW=YCTZseSanpNeF_+Sw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>     > void phy_disconnect(struct phy_device *phydev)
>     > {
>     >         if (phydev->irq > 0)
>     >                 phy_stop_interrupts(phydev);
>     >
>     >         phy_stop_machine(phydev);
>     >
>     >         phydev->adjust_link = NULL;
>     >
>     >         phy_detach(phydev);
>     > }
> 
>     And this does not yet get called. It probably needs to be in
>     dsa_switch_destroy() just before unregister_netdev() of the slave
>     devices.
> 
>     However, the ordering in dsa_switch_destroy() looks wrong. The fixed
>     phys are destroyed before the slave devices. They should probably be
>     destroyed after the slave devices, or at least after the
>     phy_disconnect() is called.
> 
>                      Andrew
> 

Andrew, Florian,

Thanks for the review, a call to phy_disconnect was missing in dsa_switch_destroy.

I will post a new patchset with the correct fix, a switch to delayed_work and
a separate dsa_slave_destroy function for sake of maintenance ease.

Neil
