From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH net-next 09/15] ethernet/dlink: use core min/max MTU
 checking
Date: Tue, 18 Oct 2016 11:04:52 -0400
Message-ID: <20161018150452.GU14983@redhat.com>
References: <20161017195417.48259-1-jarod@redhat.com>
 <20161017195417.48259-10-jarod@redhat.com>
 <CAOJe8K0Yme_do82WgD7L+eWsvbC2nSQr13Kohj0Jd3coAeHfrg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Denis Kirjanov <kda@linux-powerpc.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAOJe8K0Yme_do82WgD7L+eWsvbC2nSQr13Kohj0Jd3coAeHfrg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 18, 2016 at 04:45:51PM +0300, Denis Kirjanov wrote:
> On 10/17/16, Jarod Wilson <jarod@redhat.com> wrote:
> > dl2k: min_mtu 68, max_mtu 1536 or 8000, depending on hardware
> > - Removed change_mtu, does nothing productive anymore
> >
> > sundance: min_mtu 68, max_mtu 8191
> >
> > CC: netdev@vger.kernel.org
> > CC: Denis Kirjanov <kda@linux-powerpc.org>
> > Signed-off-by: Jarod Wilson <jarod@redhat.com>
> > ---
> >  drivers/net/ethernet/dlink/dl2k.c     | 22 ++++------------------
> >  drivers/net/ethernet/dlink/sundance.c |  6 ++++--
> >  2 files changed, 8 insertions(+), 20 deletions(-)
...
> > diff --git a/drivers/net/ethernet/dlink/sundance.c
> > b/drivers/net/ethernet/dlink/sundance.c
> > index 79d8009..eab36ac 100644
> > --- a/drivers/net/ethernet/dlink/sundance.c
> > +++ b/drivers/net/ethernet/dlink/sundance.c
> > @@ -580,6 +580,10 @@ static int sundance_probe1(struct pci_dev *pdev,
> >  	dev->ethtool_ops = &ethtool_ops;
> >  	dev->watchdog_timeo = TX_TIMEOUT;
> >
> > +	/* MTU range: 68 - 8191 */
> > +	dev->min_mtu = ETH_MIN_MTU;
> > +	dev->max_mtu = 8191;
> > +
> ICPlus datasheet defines the max frame size like 0x1514 or 0x4491
> based on the RcvLargeFrames bit in the MACCtrl0 register

I do anticipate this patchset might bring to light some inaccuracies in
min/max mtu values currently implemented in various drivers, but for the
moment, I'm going for 100% identical behavior with what's currently in the
driver, and if you'll look down below...

> >  	pci_set_drvdata(pdev, dev);
> >
> >  	i = register_netdev(dev);
> > @@ -713,8 +717,6 @@ static int sundance_probe1(struct pci_dev *pdev,
> >
> >  static int change_mtu(struct net_device *dev, int new_mtu)
> >  {
> > -	if ((new_mtu < 68) || (new_mtu > 8191)) /* Set by RxDMAFrameLen */

                                         ^^^^
The 8191 was simply transplanted from right here. I think altering the
value should be the subject of a separate patch.

-- 
Jarod Wilson
jarod@redhat.com
