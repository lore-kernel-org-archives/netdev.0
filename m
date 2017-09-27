From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net v2] net: dsa: mv88e6xxx: lock mutex when freeing IRQs
Date: Wed, 27 Sep 2017 15:07:11 +0200
Message-ID: <20170927130711.GD13516@lunn.ch>
References: <20170926185721.12187-1-vivien.didelot@savoirfairelinux.com>
 <063D6719AE5E284EB5DD2968C1650D6DD00822B6@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Vivien Didelot' <vivien.didelot@savoirfairelinux.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "kernel@savoirfairelinux.com" <kernel@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD00822B6@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 27, 2017 at 09:06:01AM +0000, David Laight wrote:
> From: Vivien Didelot
> > Sent: 26 September 2017 19:57
> > mv88e6xxx_g2_irq_free locks the registers mutex, but not
> > mv88e6xxx_g1_irq_free, which results in a stack trace from
> > assert_reg_lock when unloading the mv88e6xxx module. Fix this.
> > 
> > Fixes: 3460a5770ce9 ("net: dsa: mv88e6xxx: Mask g1 interrupts and free interrupt")
> > Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> > ---
> >  drivers/net/dsa/mv88e6xxx/chip.c | 2 ++
> >  1 file changed, 2 insertions(+)
> > 
> > diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
> > index c6678aa9b4ef..e7ff7483d2fb 100644
> > --- a/drivers/net/dsa/mv88e6xxx/chip.c
> > +++ b/drivers/net/dsa/mv88e6xxx/chip.c
> > @@ -3947,7 +3947,9 @@ static void mv88e6xxx_remove(struct mdio_device *mdiodev)
> >  	if (chip->irq > 0) {
> >  		if (chip->info->g2_irqs > 0)
> >  			mv88e6xxx_g2_irq_free(chip);
> > +		mutex_lock(&chip->reg_lock);
> >  		mv88e6xxx_g1_irq_free(chip);
> > +		mutex_unlock(&chip->reg_lock);
> 
> Isn't the irq_free code likely to have to sleep waiting for any
> ISR to complete??

Hi David

Possibly. But this is a mutex, not a spinlock. So sleeping is O.K.
Or am i missing something?

	  Andrew
