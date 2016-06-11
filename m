From: Scott Wood <oss-fOR+EgIDQEHk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH 3/4] mmc: sdhci-of-esdhc: fix host version for
	T4240-R1.0-R2.0
Date: Fri, 10 Jun 2016 21:00:16 -0500
Message-ID: <1465610416.22191.160.camel@buserror.net>
References: <1462417950-46796-1-git-send-email-yangbo.lu@nxp.com>
	<6110875.0k1HlSKhzn@wuerfel> <1464829874.16584.163.camel@buserror.net>
	<3851136.KiJNtFycNm@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Ulf Hansson <ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	Bhupesh Sharma <bhupesh.sharma-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Yangbo Lu <yangbo.lu-3arQi8VN3Tc@public.gmane.org>,
	"linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Xiaobo Xie <xiaobo.xie-3arQi8VN3Tc@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Claudiu Manoil <claudiu.manoil-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Santosh Shilimkar <ssantosh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Yang-Leo Li <leoyang.li-3arQi8VN3Tc@public.gmane.org>,
	"linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-a
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <3851136.KiJNtFycNm@wuerfel>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-06-02 at 10:52 +0200, Arnd Bergmann wrote:
> On Wednesday, June 1, 2016 8:11:14 PM CEST Scott Wood wrote:
> > > +#define T4240_HOST_VER ((VENDOR_V_23 << SDHCI_VENDOR_VER_SHIFT) |
> > > SDHCI_SPEC_200)
> > > +static const struct soc_device_attribute esdhc_t4240_quirk = {
> > > +     /* T4240 revision < 0x20 uses vendor version 23, SDHCI version 200
> > > */
> > > +     { .soc_id = "T4*(0x824000)", .revision = "0x[01]?",
> > > +       .data = (void *)(uintptr_t)(T4240_HOST_VER) },
> > 
> > Why should this code need to care that the string begins with "T4"?  This
> > creates dual maintenance if that were to change.  It's also broken because
> > T4240 has compatible = "fsl,t4240-device-config", "fsl,qoriq-device-config
> > -2.0" and thus with these patches it would incorrectly show up as "P
> > series
> > (0x824000)".  The compatible string of this node was never meant to be a
> > key
> > for choosing a string to describe the system to userspace.
> 
> This is an artifact of not knowing the specific SoC name, and we can change
> that by looking up the name from the SVR value in the soc_device driver.

...or we could keep it simple and just match the number.

> > 0x824000 is a magic number which should be represented symbolically.
> 
> Sure, feel free to change the format of the soc_device string in any
> name,

That's not what I was asking for...  The match should be numeric but the
knowledge of what the number is should come from a symbolic #define.

> > If T4240 is affected, then so are the reduced-core variants T4160 and
> > T4080,
> > but 0x824000 doesn't match them (Yangbo's patch had the same problem). 
> >  And
> > please don't respond with "0x824*"
> > 
> > You also didn't strip out the E bit of SVR which indicates encryption
> > capability and nothing else (Yangbo's patch did not have this problem
> > because
> > it used SVR_SOC_VER).
> 
> Ok, that should be easy enough to fix in the soc_device driver.

No, because the soc_device driver doesn't know whether the consumer of the ID
cares about the E bit.

> > What happens if the revision condition is more complicated, such as <=
> > 0x20
> > with 0x21 being fine?  Multiple quirk entries where before we had as
> > simple
> > comparison?
> 
> I guess yes. I would really hope that there is no need to use this interface
> pervasively, it's really just to work around the cases where there is no
> way to pass the information in DT otherwise.

How does putting it in the DT work when you have multiple versions of the same
SoC, some of which have the bug and some which don't?

> > I fail to see how this approach is an improvement (much less one that
> > needs to
> > hold up a patchset that is fixing a problem and is not touching any
> > generic
> > code).  Why does this need to be a string?
> 
> A string is what user space gets in /sys/devices/soc/*,

It is rare that the kernel accesses information in the exact same way that
userspace does.  And once we expose this to userspace we're stuck with it, so
exporting anything other than a simple number is even less desirable.

>  and we already have
> code that does the same things there to work around quirks, here we just
> use the same interface in a completely generic way. Note that not every
> SoC family uses numbers in the same way, some have multiple subrevisions,
> some have names etc.

Where is the need for a "completely generic way" for one piece of vendor
-specific code to get information that is inherently specific to that vendor,
that is supplied by code specific to that vendor?

-Scott
