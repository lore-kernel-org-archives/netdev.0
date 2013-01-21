From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 01/21] NTB: correct missing readq/writeq errors
Date: Mon, 21 Jan 2013 20:34:53 +0000
Message-ID: <1358800493.3758.10.camel@bwh-desktop.uk.solarflarecom.com>
References: <1358586155-23322-1-git-send-email-jon.mason@intel.com>
	 <1358586155-23322-2-git-send-email-jon.mason@intel.com>
	 <20130120234005.GA14196@kroah.com> <20130121173818.GD22208@jonmason-lab>
	 <20130121182345.GC5499@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jon Mason <jon.mason@intel.com>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, Dave Jiang <dave.jiang@intel.com>,
	Nicholas Bellinger <nab@linux-iscsi.org>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130121182345.GC5499@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-01-21 at 10:23 -0800, Greg KH wrote:
> On Mon, Jan 21, 2013 at 10:38:18AM -0700, Jon Mason wrote:
> > On Sun, Jan 20, 2013 at 03:40:05PM -0800, Greg KH wrote:
> > > On Sat, Jan 19, 2013 at 02:02:15AM -0700, Jon Mason wrote:
> > > > Atomic readq and writeq do not exist by default on some 32bit
> > > > architectures, thus causing compile errors due to non-existent symbols.
> > > > In those cases, use the definitions of those symbols from
> > > > include/asm-generic/io-64-nonatomic-hi-lo.h
> > > > 
> > > > Signed-off-by: Jon Mason <jon.mason@intel.com>
> > > > ---
> > > >  drivers/ntb/ntb_hw.c |    1 +
> > > >  1 file changed, 1 insertion(+)
> > > > 
> > > > diff --git a/drivers/ntb/ntb_hw.c b/drivers/ntb/ntb_hw.c
> > > > index 4c71b17..0b46fef 100644
> > > > --- a/drivers/ntb/ntb_hw.c
> > > > +++ b/drivers/ntb/ntb_hw.c
> > > > @@ -45,6 +45,7 @@
> > > >   * Contact Information:
> > > >   * Jon Mason <jon.mason@intel.com>
> > > >   */
> > > > +#include <asm-generic/io-64-nonatomic-hi-lo.h>
> > > 
> > > Really?  This seems really odd.  Usually we just don't build the code
> > > for any platform that doesn't have readq/writeq.  Otherwise, shouldn't
> > > those arches just include this file themselves to keep everything
> > > working?  Individual drivers shouldn't have to do this.
> > 
> > There is no readq/writeq for 32bit x86.  I was using this header file
> > to get around that.  I freely admit that I have done 0 testing on
> > 32bit, but it should work.  If you prefer I modify the Kconfig to only
> > enable this for x86_64 until such time as I test on x86_32, I will
> > happily submit that patch.
> 
> No, other drivers on 32bit x86 also use readq,

I don't think so, because it's not defined for CONFIG_X86_32.

> and do not include this
> asm header file.  So there is a proper way to do this, just dig through
> the header file include mess to determine the proper one to include.
> You should never have to include asm-generic file directly, that's the
> issue here.

Different devices can have different requirements for the order of
access to 32-bit halves of a 64-bit register.  Only the driver knows
which is right.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
