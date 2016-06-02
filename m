From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH 4/4] Revert "powerpc/fsl: Move fsl_guts.h out of
	arch/powerpc"
Date: Thu, 02 Jun 2016 11:01:45 +0200
Message-ID: <3225846.9EJ0sHv0XK@wuerfel>
References: <1462417950-46796-1-git-send-email-yangbo.lu@nxp.com>
	<5513501.AmZs7h1vI2@wuerfel>
	<1464830660.22191.6.camel@buserror.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>, Ulf Hansson <ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Qiang Zhao <qiang.zhao-3arQi8VN3Tc@public.gmane.org>, Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	Bhupesh Sharma <bhupesh.sharma-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Claudiu Manoil <claudiu.manoil-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Santosh Shilimkar <ssantosh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Xiaobo Xie <xiaobo.xie-3arQi8VN3Tc@public.gmane.org>, Yang-Leo Li <leoyang.li-3arQi8VN3Tc@public.gmane.org>,
	"iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <iomm
To: Scott Wood <oss-fOR+EgIDQEHk1uMJSBkQmQ@public.gmane.org>
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1464830660.22191.6.camel-fOR+EgIDQEHk1uMJSBkQmQ@public.gmane.org>
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

On Wednesday, June 1, 2016 8:24:20 PM CEST Scott Wood wrote:
> On Mon, 2016-05-30 at 15:18 +0200, Arnd Bergmann wrote:
> > All users of this driver are PowerPC specific and the header file
> > has no business in the global include/linux/ hierarchy, so move
> > it back before anyone starts using it on ARM.
> > 
> > This reverts commit 948486544713492f00ac8a9572909101ea892cb0.
> > 
> > Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
> > ---
> > This part of the series is not required for the eSDHC quirk,
> > but it restores the asm/fsl_guts.h header so it doesn't accidentally
> > get abused for this in the future. I found two drivers outside of
> > arch/powerpc that already accessed the registers directly, but the
> > functions look fairly contained, and can be easily hidden in an
> > #ifdef CONFIG_PPC
> 
> NACK
> 
> Besides adding ifdef pollution for no good reason, this register block is used
> on some ARM chips as well.  Why is it a problem if "anyone starts using it on
> ARM"?

It's just not a good interface when it's defined as "this is the layout of
a register area that any driver can ioremap() if they can figure out the
device node". It's not uncommon to have register areas like that, but
normally you have at the minimum a 'syscon' device to handle locking
between drivers accessing the same registers and to avoid having to map
the same area multiple times.

If we need to use 'guts' registers on ARM, we can find a way to abstract
them properly for the given use cases, using a syscon or a driver with
exported functions, but just making a PowerPC platform specific header
global to all Linux drivers by putting it into include/linux doesn't seem
right.

Note that the header file uses a structure definition rather than the more
common macros with register offsets, which is fine for a driver that has
its own registers and abstracts them, but it doesn't really work with
the regmap interface, so if we want to use it with syscon, it also needs to
be rewritten.

> BTW, of all the mailing lists you included on this CC, you seem to have left
> off the PPC list (I've added it).

Sorry, my mistake.

	Arnd
