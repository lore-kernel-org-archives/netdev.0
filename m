From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 6/6] net: phy: Stop 'phy-state-machine' and 'phy_change'
 work on remove
Date: Tue, 27 Oct 2015 22:20:45 +0100
Message-ID: <20151027212045.GC2307@lunn.ch>
References: <562F8EF1.5090504@baylibre.com>
 <562F9AEE.5050708@gmail.com>
 <CAJ03sU_+nkvN1ZeqvWx56B7cb9GDCbpTFn6gJp2OmW-CKi7QFA@mail.gmail.com>
 <562F9F06.7040402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frode Isaksen <fisaksen@baylibre.com>,
	Neil Armstrong <narmstrong@baylibre.com>,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <562F9F06.7040402@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 27, 2015 at 08:57:58AM -0700, Florian Fainelli wrote:
> (don't top post please)
> 
> On 27/10/15 08:53, Frode Isaksen wrote:
> > What will you need in the oops ? I presume you don' want everything or ?
> > 
> > The PHY state machine is not stopped with a PHY disconnect.
> 
> It is stopped with a phy_disconnect():
> 
> /**
>  * phy_disconnect - disable interrupts, stop state machine, and detach a PHY
>  *                  device
>  * @phydev: target phy_device struct
>  */
> void phy_disconnect(struct phy_device *phydev)
> {
>         if (phydev->irq > 0)
>                 phy_stop_interrupts(phydev);
> 
>         phy_stop_machine(phydev);
> 
>         phydev->adjust_link = NULL;
> 
>         phy_detach(phydev);
> }

And this does not yet get called. It probably needs to be in
dsa_switch_destroy() just before unregister_netdev() of the slave
devices.

However, the ordering in dsa_switch_destroy() looks wrong. The fixed
phys are destroyed before the slave devices. They should probably be
destroyed after the slave devices, or at least after the
phy_disconnect() is called.

		 Andrew
