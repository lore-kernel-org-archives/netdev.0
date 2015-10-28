From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH v2 3/4] net: dsa: mv88e6xxx: add common and ppu
 remove function
Date: Wed, 28 Oct 2015 15:45:05 +0100
Message-ID: <20151028144505.GH2307@lunn.ch>
References: <5630D7FC.4010509@baylibre.com>
 <20151028143524.GF2307@lunn.ch>
 <5630DD8E.4000404@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Neil Armstrong <narmstrong@baylibre.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5630DD8E.4000404@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 28, 2015 at 03:37:02PM +0100, Neil Armstrong wrote:
> Hi Andrew,
> 
> On 10/28/2015 03:35 PM, Andrew Lunn wrote:
> > On Wed, Oct 28, 2015 at 03:13:16PM +0100, Neil Armstrong wrote:
> >> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> >> index b1b14f5..6287096 100644
> >> --- a/drivers/net/dsa/mv88e6xxx.c
> >> +++ b/drivers/net/dsa/mv88e6xxx.c
> >> @@ -331,6 +331,16 @@ void mv88e6xxx_ppu_state_init(struct dsa_switch *ds)
> >>  	ps->ppu_timer.function = mv88e6xxx_ppu_reenable_timer;
> >>  }
> >>
> >> +void mv88e6xxx_ppu_state_remove(struct dsa_switch *ds)
> >> +{
> >> +	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
> >> +	
> >> +	del_timer_sync(&ps->ppu_timer);
> >> +
> >> +	cancel_work_sync(&ps->bridge_work);
> >> +	flush_work(&ps->bridge_work);
> >> +}
> >> +
> > 
> > You add this function, but you don't use it anywhere?  Also, why
> > cancel bridge work, not ppu_work? Or has that been consolidated
> > in some patch i'm missing?
> > 
> >    Andrew
> > 
> 
> It's called in the next patch, in mv88e6131_remove for mv88e6131.

Hi Neil

It would be better to split this out into a patch of its own, and
include the mv88e6131 change with it.

	Andrew
