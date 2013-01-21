From: Jon Mason <jon.mason@intel.com>
Subject: Re: [PATCH 01/21] NTB: correct missing readq/writeq errors
Date: Mon, 21 Jan 2013 10:38:18 -0700
Message-ID: <20130121173818.GD22208@jonmason-lab>
References: <1358586155-23322-1-git-send-email-jon.mason@intel.com>
 <1358586155-23322-2-git-send-email-jon.mason@intel.com>
 <20130120234005.GA14196@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dave Jiang <dave.jiang@intel.com>,
	Nicholas Bellinger <nab@linux-iscsi.org>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:35353 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752909Ab3AURiT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2013 12:38:19 -0500
Content-Disposition: inline
In-Reply-To: <20130120234005.GA14196@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 20, 2013 at 03:40:05PM -0800, Greg KH wrote:
> On Sat, Jan 19, 2013 at 02:02:15AM -0700, Jon Mason wrote:
> > Atomic readq and writeq do not exist by default on some 32bit
> > architectures, thus causing compile errors due to non-existent symbols.
> > In those cases, use the definitions of those symbols from
> > include/asm-generic/io-64-nonatomic-hi-lo.h
> > 
> > Signed-off-by: Jon Mason <jon.mason@intel.com>
> > ---
> >  drivers/ntb/ntb_hw.c |    1 +
> >  1 file changed, 1 insertion(+)
> > 
> > diff --git a/drivers/ntb/ntb_hw.c b/drivers/ntb/ntb_hw.c
> > index 4c71b17..0b46fef 100644
> > --- a/drivers/ntb/ntb_hw.c
> > +++ b/drivers/ntb/ntb_hw.c
> > @@ -45,6 +45,7 @@
> >   * Contact Information:
> >   * Jon Mason <jon.mason@intel.com>
> >   */
> > +#include <asm-generic/io-64-nonatomic-hi-lo.h>
> 
> Really?  This seems really odd.  Usually we just don't build the code
> for any platform that doesn't have readq/writeq.  Otherwise, shouldn't
> those arches just include this file themselves to keep everything
> working?  Individual drivers shouldn't have to do this.

There is no readq/writeq for 32bit x86.  I was using this header file
to get around that.  I freely admit that I have done 0 testing on
32bit, but it should work.  If you prefer I modify the Kconfig to only
enable this for x86_64 until such time as I test on x86_32, I will
happily submit that patch.

Thanks,
Jon

> 
> So, I'm not going to take this one just yet, sorry.
> 
> greg k-h
