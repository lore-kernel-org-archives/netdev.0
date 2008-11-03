From: Manuel Lauss <mano@roarinelk.homelinux.net>
Subject: Re: smc91x: commit 51ac3beffd4afaea4350526cf01fe74aaff25eff breaks
	compilation
Date: Mon, 3 Nov 2008 08:57:06 +0100
Message-ID: <20081103075706.GB18445@roarinelk.homelinux.net>
References: <20081103071720.GB18153@roarinelk.homelinux.net> <1aad82fa0811022330u3864f12che3f903a43402e043@mail.gmail.com> <20081103073534.GA18445@roarinelk.homelinux.net> <1aad82fa0811022348of69b7a0v10f4eb97a8a3f6df@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fnoeppeil48.netpark.at ([217.175.205.176]:45272 "EHLO
	roarinelk.homelinux.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751942AbYKCH5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 02:57:08 -0500
Content-Disposition: inline
In-Reply-To: <1aad82fa0811022348of69b7a0v10f4eb97a8a3f6df@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 03, 2008 at 02:48:52AM -0500, Mike Frysinger wrote:
> On Mon, Nov 3, 2008 at 2:35 AM, Manuel Lauss wrote:
> > On Mon, Nov 03, 2008 at 02:30:01AM -0500, Mike Frysinger wrote:
> >> On Mon, Nov 3, 2008 at 2:17 AM, Manuel Lauss wrote:
> >> > (Resend with correct netdev addr)
> >> >
> >> > Hi Mike,
> >> >
> >> > your commit 51ac3beffd4afaea4350526cf01fe74aaff25eff  causes this
> >> > compile failure on my SH and MIPS testboards (2.6.28-rc3):
> >> >
> >> >  CC      drivers/net/smc91x.o
> >> > /mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c: In function 'smc_request_attrib':
> >> > /mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c:2067: error: 'lp' undeclared (first use in this function)
> >> > /mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c:2067: error: (Each undeclared identifier is reported only once
> >> > /mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c:2067: error: for each function it appears in.)
> >> > /mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c: In function 'smc_release_attrib':
> >> > /mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c:2079: error: 'lp' undeclared (first use in this function)
> >> > make[2]: *** [drivers/net/smc91x.o] Error 1
> >> > make[1]: *** [drivers/net/smc91x.o] Error 2
> >> >
> >> > Reverting this commit fixes it.
> >>
> >> are you using modifiied sources or something ? there's clearly no lp
> >> reference in mainline:
> >> ...
> >> static int smc_request_attrib(struct platform_device *pdev,
> >>                   struct net_device *ndev)
> >> {
> >>     struct resource * res = platform_get_resource_byname(pdev,
> >> IORESOURCE_MEM, "smc91x-attrib");
> >>
> >>     if (!res)
> >>         return 0;
> >>
> >>     if (!request_mem_region(res->start, ATTRIB_SIZE, CARDNAME))
> >>         return -EBUSY;
> >>
> >>     return 0;
> >> }
> >>
> >> static void smc_release_attrib(struct platform_device *pdev,
> >>                    struct net_device *ndev)
> >> {
> >>     struct resource * res = platform_get_resource_byname(pdev,
> >> IORESOURCE_MEM, "smc91x-attrib");
> >>
> >>     if (res)
> >>         release_mem_region(res->start, ATTRIB_SIZE);
> >> }
> >
> > No changes, pristine 2.6.28-rc3.  Note that I don't have any board entries
> > in smc91x.h; just platform_data.
> 
> then you'll need to generate the preprocessed output and figure out
> where the lp reference is coming from.
> make drivers/net/smc91x.i

Here you go:

static int smc_request_attrib(struct platform_device *pdev,
         struct net_device *ndev)
{
 struct resource * res = platform_get_resource_byname(pdev, 0x00000200,
"smc91x-attrib");

 if (!res)
  return 0;

 if (!__request_region(&iomem_resource, (res->start), (((64*1024) <<
(lp->io_shift))), ("smc91x")))
  return -16;

 return 0;
}

-- ml.
