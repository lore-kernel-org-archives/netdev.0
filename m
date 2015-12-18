From: Damien Riegel <damien.riegel@savoirfairelinux.com>
Subject: Re: [PATCH 2/2] can: sja1000: of: add compatibility with Technologic
 Systems version
Date: Fri, 18 Dec 2015 16:02:31 -0500
Message-ID: <20151218210231.GA6116@localhost>
References: <1450469845-12900-1-git-send-email-damien.riegel@savoirfairelinux.com>
 <1450469845-12900-2-git-send-email-damien.riegel@savoirfairelinux.com>
 <56746F8B.8030008@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, devicetree@vger.kernel.org,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	kernel@savoirfairelinux.com
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56746F8B.8030008@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 18, 2015 at 09:41:47PM +0100, Marc Kleine-Budde wrote:
> On 12/18/2015 09:17 PM, Damien Riegel wrote:
> > Technologic Systems provides an IP compatible with the SJA1000,
> > instantiated in an FPGA. Because of some bus widths issue, access to
> > registers is made through a "window" that works like this:
> > 
> >     base + 0x0: address to read/write
> >     base + 0x2: 8-bit register value
> > 
> > This commit adds a new compatible device, "technologic,sja1000", with
> > read and write functions using the window mechanism.
> > 
> > Signed-off-by: Damien Riegel <damien.riegel@savoirfairelinux.com>
> > ---
> >  drivers/net/can/sja1000/sja1000_platform.c | 30 ++++++++++++++++++++++++++++--
> >  1 file changed, 28 insertions(+), 2 deletions(-)
> > 
> > diff --git a/drivers/net/can/sja1000/sja1000_platform.c b/drivers/net/can/sja1000/sja1000_platform.c
> > index 0552ed4..6cbf251 100644
> > --- a/drivers/net/can/sja1000/sja1000_platform.c
> > +++ b/drivers/net/can/sja1000/sja1000_platform.c
> > @@ -70,6 +70,18 @@ static void sp_write_reg32(const struct sja1000_priv *priv, int reg, u8 val)
> >  	iowrite8(val, priv->reg_base + reg * 4);
> >  }
> >  
> > +static u8 ts4800_read_reg16(const struct sja1000_priv *priv, int reg)
> > +{
> > +	sp_write_reg16(priv, 0,  reg);
> > +	return sp_read_reg16(priv, 2);
> 
> This is racy, please add a spinlock.
> 
> > +}
> > +
> > +static void ts4800_write_reg16(const struct sja1000_priv *priv, int reg, u8 val)
> > +{
> > +	sp_write_reg16(priv, 0, reg);
> > +	sp_write_reg16(priv, 2, val);
> 
> This is racy, too.
> 
> Have a look at https://marc.info/?l=linux-can&m=137149497403825&w=2

Thank you for the link. In my situation, I don't think there is a race
issue at the bus level, so a per-device spinlock should be enough. Would
that be an acceptable patch? It would look a lot like the patch you
suggested in the thread you linked, just rebased on current version.

Thanks,
Damien
