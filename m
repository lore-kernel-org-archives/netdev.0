From: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Subject: Re: [net-next-2.6 PATCH v2] can: SJA1000: generic OF platform bus
	driver
Date: Tue, 26 May 2009 19:40:43 +1000
Message-ID: <1243330843.2858.71.camel@pasglop>
References: <4A16BAAE.3070401@grandegger.com>
	<200905242327.15139.arnd@arndb.de> <4A1A418D.3040207@grandegger.com>
	<200905261010.31364.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, devicetree-discuss-mnsaURCQ41sdnm+yROfE0A@public.gmane.org,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-mnsaURCQ41sdnm+yROfE0A@public.gmane.org>
In-Reply-To: <200905261010.31364.arnd-r2nGTMty4D4@public.gmane.org>
List-Unsubscribe: <https://ozlabs.org/mailman/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-mnsaURCQ41sdnm+yROfE0A@public.gmane.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-mnsaURCQ41sdnm+yROfE0A@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-mnsaURCQ41sdnm+yROfE0A@public.gmane.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-mnsaURCQ41sdnm+yROfE0A@public.gmane.org?subject=subscribe>
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2009-05-26 at 10:10 +0100, Arnd Bergmann wrote:
> On Monday 25 May 2009, Wolfgang Grandegger wrote:
> > > Right, that makes sense. However, most drivers use the field to store the
> > > physical address, not the iomap token. Maybe there should be a new field
> > > in struct sja1000_priv for the virtual address, but that would be a change
> > > to the base driver, not just to the OF portion.
> > 
> > Is that common practice? If yes, I will add a member to store the
> > virtual address to struct sja1000_priv.
> 
> I grepped through the network driver for usage of ->base_addr, and
> it's somewhat inconsistent. The majority of the users use it for
> a physical address, but there are also a few that use it for the
> __iomem token.

In addition, iirc, it's not big enough to hold >32 bit physical
addresses on 32-bit platforms no ?

Ben.

> Casts between unsigned long and qualified (__iomem, __user, const, ...)
> pointers do not cause a warning, but can easily lead to bugs when
> another user casts to an unqualified pointer.
> 
> 	Arnd <><
> 
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
> https://ozlabs.org/mailman/listinfo/linuxppc-dev
