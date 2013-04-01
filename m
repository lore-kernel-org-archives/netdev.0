From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH] of_net.h: Provide dummy functions if OF_NET is not
 configured
Date: Mon, 1 Apr 2013 12:01:00 -0700
Message-ID: <20130401190100.GA1042@roeck-us.net>
References: <1364840349-10696-1-git-send-email-linux@roeck-us.net>
 <5159D588.5070603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Rob Herring <rob.herring@calxeda.com>,
	David Daney <david.daney@cavium.com>
To: Rob Herring <robherring2@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5159D588.5070603@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 01, 2013 at 01:44:24PM -0500, Rob Herring wrote:
> On 04/01/2013 01:19 PM, Guenter Roeck wrote:
> > of_get_mac_address() and of_get_phy_mode() are only provided if OF_NET
> > is configured. While most callers check for the define, not all do, and those
> > who do require #ifdef around the code. For those who don't, the missing check
> > can result in errors such as
> 
> How about removing the ifdef from those callers?
> 
That would be the next step, after/if this one is accepted.
If not, it doesn't make sense to waste my time.

Thanks,
Guenter

> Rob
> 
> > 
> > arch/powerpc/sysdev/tsi108_dev.c:107:3: error: implicit declaration of
> > 	function 'of_get_mac_address' [-Werror=implicit-function-declaration]
> > arch/powerpc/sysdev/mv64x60_dev.c:253:2: error: implicit declaration of
> > 	function 'of_get_mac_address' [-Werror=implicit-function-declaration]
> > 
> > Provide dummy function declarations if OF_NET is not configured. This is safe
> > because all callers do check the return values. If desired, at least some of
> > the #ifdefs in the code can subsequently be removed.
> > 
> > Cc: David Daney <david.daney@cavium.com>
> > Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> > ---
> >  include/linux/of_net.h |   10 ++++++++++
> >  1 file changed, 10 insertions(+)
> > 
> > diff --git a/include/linux/of_net.h b/include/linux/of_net.h
> > index f474641..61bf53b 100644
> > --- a/include/linux/of_net.h
> > +++ b/include/linux/of_net.h
> > @@ -11,6 +11,16 @@
> >  #include <linux/of.h>
> >  extern const int of_get_phy_mode(struct device_node *np);
> >  extern const void *of_get_mac_address(struct device_node *np);
> > +#else
> > +static inline const int of_get_phy_mode(struct device_node *np)
> > +{
> > +	return -ENODEV;
> > +}
> > +
> > +static inline const void *of_get_mac_address(struct device_node *np)
> > +{
> > +	return NULL;
> > +}
> >  #endif
> >  
> >  #endif /* __LINUX_OF_NET_H */
> > 
> 
> 
