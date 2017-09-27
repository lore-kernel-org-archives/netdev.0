From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net v2] net: dsa: mv88e6xxx: lock mutex when freeing IRQs
Date: Wed, 27 Sep 2017 16:40:34 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD00829F0@AcuExch.aculab.com>
References: <20170926185721.12187-1-vivien.didelot@savoirfairelinux.com>
 <063D6719AE5E284EB5DD2968C1650D6DD00822B6@AcuExch.aculab.com>
 <20170927130711.GD13516@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: 'Vivien Didelot' <vivien.didelot@savoirfairelinux.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "kernel@savoirfairelinux.com" <kernel@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: 'Andrew Lunn' <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170927130711.GD13516@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Lunn
> Sent: 27 September 2017 14:07
> To: David Laight
> On Wed, Sep 27, 2017 at 09:06:01AM +0000, David Laight wrote:
> > From: Vivien Didelot
> > > Sent: 26 September 2017 19:57
> > > mv88e6xxx_g2_irq_free locks the registers mutex, but not
> > > mv88e6xxx_g1_irq_free, which results in a stack trace from
> > > assert_reg_lock when unloading the mv88e6xxx module. Fix this.
> > >
> > > Fixes: 3460a5770ce9 ("net: dsa: mv88e6xxx: Mask g1 interrupts and free interrupt")
> > > Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> > > ---
> > >  drivers/net/dsa/mv88e6xxx/chip.c | 2 ++
> > >  1 file changed, 2 insertions(+)
> > >
> > > diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
> > > index c6678aa9b4ef..e7ff7483d2fb 100644
> > > --- a/drivers/net/dsa/mv88e6xxx/chip.c
> > > +++ b/drivers/net/dsa/mv88e6xxx/chip.c
> > > @@ -3947,7 +3947,9 @@ static void mv88e6xxx_remove(struct mdio_device *mdiodev)
> > >  	if (chip->irq > 0) {
> > >  		if (chip->info->g2_irqs > 0)
> > >  			mv88e6xxx_g2_irq_free(chip);
> > > +		mutex_lock(&chip->reg_lock);
> > >  		mv88e6xxx_g1_irq_free(chip);
> > > +		mutex_unlock(&chip->reg_lock);
> >
> > Isn't the irq_free code likely to have to sleep waiting for any
> > ISR to complete??
> 
> Hi David
> 
> Possibly. But this is a mutex, not a spinlock. So sleeping is O.K.
> Or am i missing something?

Looks like I was missing some coffee :-)

	David
