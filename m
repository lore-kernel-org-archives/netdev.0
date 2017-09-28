From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next RFC 3/9] net: dsa: mv88e6xxx: add support for
 GPIO configuration
Date: Thu, 28 Sep 2017 20:01:11 +0200
Message-ID: <20170928180111.GF14940@lunn.ch>
References: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
 <1506612341-18061-4-git-send-email-brandon.streiff@ni.com>
 <659c4254-d0b7-52dc-dd9b-3921cd2f20c0@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brandon Streiff <brandon.streiff@ni.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Richard Cochran <richardcochran@gmail.com>,
        Erik Hons <erik.hons@ni.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <659c4254-d0b7-52dc-dd9b-3921cd2f20c0@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 28, 2017 at 10:45:03AM -0700, Florian Fainelli wrote:
> On 09/28/2017 08:25 AM, Brandon Streiff wrote:
> > The Scratch/Misc register is a windowed interface that provides access
> > to the GPIO configuration. Provide a new method for configuration of
> > GPIO functions.
> > 
> > Signed-off-by: Brandon Streiff <brandon.streiff@ni.com>
> > ---
> 
> > +/* Offset 0x1A: Scratch and Misc. Register */
> > +static int mv88e6xxx_g2_scratch_reg_read(struct mv88e6xxx_chip *chip,
> > +					 int reg, u8 *data)
> > +{
> > +	int err;
> > +	u16 value;
> > +
> > +	err = mv88e6xxx_g2_write(chip, MV88E6XXX_G2_SCRATCH_MISC_MISC,
> > +				 reg << 8);
> > +	if (err)
> > +		return err;
> > +
> > +	err = mv88e6xxx_g2_read(chip, MV88E6XXX_G2_SCRATCH_MISC_MISC, &value);
> > +	if (err)
> > +		return err;
> > +
> > +	*data = (value & MV88E6XXX_G2_SCRATCH_MISC_DATA_MASK);
> > +
> > +	return 0;
> > +}
> 
> With the write and read acquiring and then releasing the lock
> immediately, is no there room for this sequence to be interrupted in the
> middle and end-up returning inconsistent reads?

Hi Florian

The general pattern in this code is that the lock chip->reg_lock is
taken at a higher level. That protects against other threads. The
driver tends to do that at the highest levels, at the entry points
into the driver. I've not yet checked this code follows the pattern
yet. However, we have a check in the low level to ensure the lock has
been taken. So it seems likely the lock is held.
 
> Would there be any value in implementing a proper gpiochip structure
> here such that other pieces of SW can see this GPIO controller as a
> provider and you can reference it from e.g: Device Tree using GPIO
> descriptors?

That would be my preference as well, or maybe a pinctrl driver.

     Andrew
