From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: Re: [PATCH v6 net-next 01/17] net: qualcomm: remove unnecessary
 includes
Date: Wed, 24 May 2017 22:05:26 +0200 (CEST)
Message-ID: <1746915556.279475.1495656327010@email.1und1.de>
References: <1495545173-22150-1-git-send-email-stefan.wahren@i2se.com>
 <1495545173-22150-2-git-send-email-stefan.wahren@i2se.com>
 <20170524.154111.404338711401048909.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-serial@vger.kernel.org, jslaby@suse.com,
        gregkh@linuxfoundation.org, netdev@vger.kernel.org,
        robh+dt@kernel.org, linux-kernel@vger.kernel.org, kubakici@wp.pl,
        mark.rutland@arm.com, LinoSanfilippo@gmx.de,
        devicetree@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170524.154111.404338711401048909.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> David Miller <davem@davemloft.net> hat am 24. Mai 2017 um 21:41 geschrieben:
> 
> 
> From: Stefan Wahren <stefan.wahren@i2se.com>
> Date: Tue, 23 May 2017 15:12:37 +0200
> 
> > Most of the includes in qca_7k.c are unnecessary so we better remove them.
> > 
> > Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
> > ---
> >  drivers/net/ethernet/qualcomm/qca_7k.c | 4 ----
> >  1 file changed, 4 deletions(-)
> > 
> > diff --git a/drivers/net/ethernet/qualcomm/qca_7k.c b/drivers/net/ethernet/qualcomm/qca_7k.c
> > index f0066fb..557d53c 100644
> > --- a/drivers/net/ethernet/qualcomm/qca_7k.c
> > +++ b/drivers/net/ethernet/qualcomm/qca_7k.c
> > @@ -23,11 +23,7 @@
> >   *   kernel-based SPI device.
> >   */
> >  
> > -#include <linux/init.h>
> > -#include <linux/module.h>
> > -#include <linux/moduleparam.h>
> >  #include <linux/spi/spi.h>
> > -#include <linux/version.h>
> >  
> >  #include "qca_7k.h"
> >  
> > -- 
> > 2.1.4
> > 
> 
> Changes like this drive me crazy.
> 
> The only reason you can remove those headers is because you are obtaining
> things indirectly via qca_7k.h
> 
> And if that is indeed the case, you are also getting qca_spi.h which
> in turn includes linux/spi/spi.h
> 
> So you could have removed that as well.
> 
> But seriously, it is so much harder to understand a driver and what
> interfaces it needs via header files when you hide _all_ of it behind
> these local private header files which just include _everything_
> and then _every_ foo.c file in your driver gets _all_ of those kernel
> headers whether they need it or not.
> 
> So if just one foo.c file needs 20 extra kernel headers than the rest
> of the files in the driver, every foo.c file eats that cost of
> including them.
> 
> I really don't like when drivers move in this direction for that
> reason.  And at best, as described at the beginning of my response,
> this change is incomplete.
>

The intension of this change wasn't to hide the includes into qca_7k.h

AFAIK these ones above aren't necessary (no init, no kernel module, no kernel parameter, no kernel version) for this C file. So i will double check it.
