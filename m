From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 2/2] net: add support for NS8390 based eth controllers
 on some ColdFire CPU boards
Date: Tue, 03 Jul 2012 23:39:59 -0700
Message-ID: <1341383999.3627.20.camel@joe2Laptop>
References: <1341377789-12970-1-git-send-email-gerg@snapgear.com>
	 <1341377789-12970-3-git-send-email-gerg@snapgear.com>
	 <1341379091.3627.15.camel@joe2Laptop> <4FF3E031.5040703@snapgear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-m68k@vger.kernel.org,
	Greg Ungerer <gerg@uclinux.org>
To: Greg Ungerer <gerg@snapgear.com>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <4FF3E031.5040703@snapgear.com>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-07-04 at 16:18 +1000, Greg Ungerer wrote:
> Hi Joe,

Hi Greg.

> On 04/07/12 15:18, Joe Perches wrote:
> > On Wed, 2012-07-04 at 14:56 +1000, gerg@snapgear.com wrote:
> >> From: Greg Ungerer <gerg@uclinux.org>
> >>
> >> A number of older ColdFire CPU based boards use NS8390 based network
> >> controllers. Most use the Davicom 9008F or the UMC 9008F. This driver
> >> provides the support code to get these devices working on these platforms.
[]
> >> diff --git a/drivers/net/ethernet/8390/mcf8390.c b/drivers/net/ethernet/8390/mcf8390.c
[]
> >> +static int mcf8390_init(struct net_device *dev)
> >> +{
> >> +	static u32 offsets[] = {
> >> +		0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
> >> +		0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
> >> +	};
> >
> > const?  u8?
> 
> That is assigned to the "reg_offset" field of "struct ei_device"
> (defined in the existing 8390.h) and that is:
> 
>      u32 *reg_offset;		/* Register mapping table */
> 
> So I can't change this.

Sure you can, you can assign a u8 to a u32 just fine.

The value fits in a u8.  Might as well make it take
less data space.  static const makes it read-only and
makes the compiler assign it just once instead of at
function invocation.

cheers, Joe
