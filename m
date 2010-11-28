From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH 5/6] forcedeth: use KERN_ facility level in printk
Date: Sun, 28 Nov 2010 10:05:21 +0100
Message-ID: <AANLkTi=X-4mg2SyKx870B1xN4uW+4NPuPL=Fv_cqYf--@mail.gmail.com>
References: <1290883188-2078-1-git-send-email-szymon@janc.net.pl>
	<1290883188-2078-6-git-send-email-szymon@janc.net.pl>
	<1290884641.3292.0.camel@localhost>
	<1290887140.22971.16.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Szymon Janc <szymon@janc.net.pl>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:55593 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751824Ab0K1JFX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Nov 2010 04:05:23 -0500
Received: by qwb7 with SMTP id 7so3403029qwb.19
        for <netdev@vger.kernel.org>; Sun, 28 Nov 2010 01:05:22 -0800 (PST)
In-Reply-To: <1290887140.22971.16.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/11/27 Joe Perches <joe@perches.com>:
> On Sat, 2010-11-27 at 19:04 +0000, Ben Hutchings wrote:
>> On Sat, 2010-11-27 at 19:39 +0100, Szymon Janc wrote:
>> > diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
>> > index 2f092d7..a2b6681 100644
>> > --- a/drivers/net/forcedeth.c
>> > +++ b/drivers/net/forcedeth.c
>> > @@ -958,7 +958,7 @@ static int reg_delay(struct net_device *dev, i=
nt offset, u32 mask, u32 target,
>> > =A0 =A0 =A0 =A0 =A0 =A0 delaymax -=3D delay;
>> > =A0 =A0 =A0 =A0 =A0 =A0 if (delaymax < 0) {
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (msg)
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk("%s",=
 msg);
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_=
WARNING "%s", msg);
>> No, msg already includes a log level.
>
> True. =A0The messages are still broken though.
> Some have trailing newlines, others not.
>
> It'd be better to move the msg after the reg_delay
> call and add the missing newlines.
>
[...]
> diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
> index 0fa1776..2d11028f 100644
> --- a/drivers/net/forcedeth.c
> +++ b/drivers/net/forcedeth.c
[...]
> @@ -1547,9 +1544,9 @@ static void nv_stop_rx(struct net_device *dev)
> =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rx_ctrl |=3D NVREG_RCVCTL_RX_PATH_EN;
> =A0 =A0 =A0 =A0writel(rx_ctrl, base + NvRegReceiverControl);
> - =A0 =A0 =A0 reg_delay(dev, NvRegReceiverStatus, NVREG_RCVSTAT_BUSY,=
 0,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NV_RXSTOP_DELAY1, NV_RX=
STOP_DELAY1MAX,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 KERN_INFO "nv_stop_rx: =
ReceiverStatus remained busy");
> + =A0 =A0 =A0 if (reg_delay(dev, NvRegReceiverStatus, NVREG_RCVSTAT_B=
USY, 0,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NV_RXSTOP_DELAY1, NV_RXSTOP=
_DELAY1MAX))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_INFO "nv_stop_rx: ReceiverS=
tatus remained busy\n");

You could change it to dev_info() and friends in one go.

> =A0 =A0 =A0 =A0udelay(NV_RXSTOP_DELAY2);
> =A0 =A0 =A0 =A0if (!np->mac_in_use)
[...]

Best Regards,
Micha=B3 Miros=B3aw
