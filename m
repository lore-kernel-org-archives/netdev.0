From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH 2.6.11 1/8] tg3: add 5705_plus flag
Date: Wed, 23 Mar 2005 17:51:52 -0800
Message-ID: <20050324015152.GB25554@waste.org>
References: <B1508D50A0692F42B217C22C02D84972020F3E21@NT-IRVA-0741.brcm.ad.broadcom.com> <4240858B.5080209@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Chan <mchan@broadcom.com>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4240858B.5080209@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Mar 22, 2005 at 03:52:27PM -0500, Jeff Garzik wrote:
> Michael Chan wrote:
> >Add a 5705_plus flag to indicate the device is 5705, 5750, or future chips
> >that all share the same basic architecture. This makes it easier to add
> >support for future devices.
> >
> >
> >Signed-off-by: Michael Chan <mchan@broadcom.com
> 
> ACK, and two comments:
> 
> 1) In general, I encourage changes like this, for both tg3 and other net 
> drivers.  It is -much- better to define a feature flag, and test the 
> feature flag in the source code, than to define a list of affected 
> [chips | arches].  Changes like this
> 
> -       if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705 ||
> -           GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5750) {
> +       if (tp->tg3_flags2 & TG3_FLG2_5705_PLUS) {
> 
> can be an example to others for future changes.

Except this isn't really a feature flag, per se. That would be
something like TG3_HAS_FOO, in other words "what particular feature
this if statement actually cares about". What is currently 5705_PLUS
would then be a bunch of flags HAS_SENSIBLE_X | HAS_FAST_Y | HAS_WORKING_Z.

The "family flag" approach is fine until you run into something that
has X and Y but not Z.

-- 
Mathematics is the supreme nostalgia of our time.
