From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 5/6] forcedeth: use KERN_ facility level in printk
Date: Sun, 28 Nov 2010 01:11:43 -0800
Message-ID: <1290935503.16349.7.camel@Joe-Laptop>
References: <1290883188-2078-1-git-send-email-szymon@janc.net.pl>
	 <1290883188-2078-6-git-send-email-szymon@janc.net.pl>
	 <1290884641.3292.0.camel@localhost> <1290887140.22971.16.camel@Joe-Laptop>
	 <AANLkTi=X-4mg2SyKx870B1xN4uW+4NPuPL=Fv_cqYf--@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Szymon Janc <szymon@janc.net.pl>, netdev@vger.kernel.org
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1897 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750980Ab0K1JLp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Nov 2010 04:11:45 -0500
In-Reply-To: <AANLkTi=X-4mg2SyKx870B1xN4uW+4NPuPL=Fv_cqYf--@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-11-28 at 10:05 +0100, Micha=C5=82 Miros=C5=82aw wrote:
> 2010/11/27 Joe Perches <joe@perches.com>:
> > On Sat, 2010-11-27 at 19:04 +0000, Ben Hutchings wrote:
> >> On Sat, 2010-11-27 at 19:39 +0100, Szymon Janc wrote:
> >> > diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
> >> > index 2f092d7..a2b6681 100644
> >> > @@ -958,7 +958,7 @@ static int reg_delay(struct net_device *dev,=
 int offset, u32 mask, u32 target,
[]
> >> > -                           printk("%s", msg);
> >> > +                           printk(KERN_WARNING "%s", msg);
> >> No, msg already includes a log level.
> > True.  The messages are still broken though.
> > Some have trailing newlines, others not.
> > It'd be better to move the msg after the reg_delay
> > call and add the missing newlines.
> [...]
> > diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
> > @@ -1547,9 +1544,9 @@ static void nv_stop_rx(struct net_device *dev=
)
[]
> > -       reg_delay(dev, NvRegReceiverStatus, NVREG_RCVSTAT_BUSY, 0,
> > -                       NV_RXSTOP_DELAY1, NV_RXSTOP_DELAY1MAX,
> > -                       KERN_INFO "nv_stop_rx: ReceiverStatus remai=
ned busy");
> > +       if (reg_delay(dev, NvRegReceiverStatus, NVREG_RCVSTAT_BUSY,=
 0,
> > +                     NV_RXSTOP_DELAY1, NV_RXSTOP_DELAY1MAX))
> > +               printk(KERN_INFO "nv_stop_rx: ReceiverStatus remain=
ed busy\n");
> You could change it to dev_info() and friends in one go.

Yeah, I did that in a local tree for all logging calls,
(dprintk->netdev_dbg, printk->netdev_<level> etc) but I'll
wait until Szymon's patches are applied or nacked.


