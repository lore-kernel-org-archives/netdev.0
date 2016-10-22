From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH net-next 09/15] ethernet/dlink: use core min/max MTU
 checking
Date: Sat, 22 Oct 2016 11:54:32 +0200
Message-ID: <20161022115432.5936df44@kant>
References: <20161017195417.48259-1-jarod@redhat.com>
        <20161017195417.48259-10-jarod@redhat.com>
        <CAOJe8K0Yme_do82WgD7L+eWsvbC2nSQr13Kohj0Jd3coAeHfrg@mail.gmail.com>
        <20161018150452.GU14983@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Denis Kirjanov <kda@linux-powerpc.org>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jarod Wilson <jarod@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:58580 "EHLO
        einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934407AbcJVJym (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Oct 2016 05:54:42 -0400
In-Reply-To: <20161018150452.GU14983@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Oct 18 Jarod Wilson wrote:
> On Tue, Oct 18, 2016 at 04:45:51PM +0300, Denis Kirjanov wrote:
> > On 10/17/16, Jarod Wilson <jarod@redhat.com> wrote:
[...]
> > > --- a/drivers/net/ethernet/dlink/sundance.c
> > > +++ b/drivers/net/ethernet/dlink/sundance.c
> > > @@ -580,6 +580,10 @@ static int sundance_probe1(struct pci_dev *pdev,
> > >  	dev->ethtool_ops = &ethtool_ops;
> > >  	dev->watchdog_timeo = TX_TIMEOUT;
> > >
> > > +	/* MTU range: 68 - 8191 */
> > > +	dev->min_mtu = ETH_MIN_MTU;
> > > +	dev->max_mtu = 8191;
> > > +  
> > ICPlus datasheet defines the max frame size like 0x1514 or 0x4491
> > based on the RcvLargeFrames bit in the MACCtrl0 register  
> 
> I do anticipate this patchset might bring to light some inaccuracies in
> min/max mtu values currently implemented in various drivers, but for the
> moment, I'm going for 100% identical behavior with what's currently in the
> driver, and if you'll look down below...
> 
> > >  	pci_set_drvdata(pdev, dev);
> > >
> > >  	i = register_netdev(dev);
> > > @@ -713,8 +717,6 @@ static int sundance_probe1(struct pci_dev *pdev,
> > >
> > >  static int change_mtu(struct net_device *dev, int new_mtu)
> > >  {
> > > -	if ((new_mtu < 68) || (new_mtu > 8191)) /* Set by RxDMAFrameLen */  
> 
>                                          ^^^^
> The 8191 was simply transplanted from right here. I think altering the
> value should be the subject of a separate patch.

You transplanted the value but dropped the comment.  Though Denis' reply
sounds like the comment should have been /* FIXME, set by RxDMAFrameLen */.
-- 
Stefan Richter
-======----- =-=- =-==-
http://arcgraph.de/sr/
