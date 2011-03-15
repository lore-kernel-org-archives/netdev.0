From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] Fix overflow of name in struct net_device, replaced
 str* and sprintf with strn* and snprintf respectivly.
Date: Tue, 15 Mar 2011 15:32:56 +0000
Message-ID: <1300203176.2758.0.camel@bwh-desktop>
References: <1300133248-2927-1-git-send-email-sasikanth.v19@gmail.com>
	 <1300134576.2584.66.camel@bwh-desktop>
	 <AANLkTi=g2rczjMAyz788np+frUvWCBuRWDt1Px+ZAM6D@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Sasikanth V <sasikanth.v19@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:50924 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757839Ab1COPdA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 11:33:00 -0400
In-Reply-To: <AANLkTi=g2rczjMAyz788np+frUvWCBuRWDt1Px+ZAM6D@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-03-15 at 20:30 +0530, Sasikanth V wrote:
> On Tue, Mar 15, 2011 at 1:59 AM, Ben Hutchings
> <bhutchings@solarflare.com> wrote:
>         On Tue, 2011-03-15 at 01:37 +0530, Sasikanth V wrote:
>         > Signed-off-by: Sasikanth V <sasikanth.v19@gmail.com>
>         > ---
>         >  net/core/dev.c |   14 +++++++-------
>         >  1 files changed, 7 insertions(+), 7 deletions(-)
>         >
>         > diff --git a/net/core/dev.c b/net/core/dev.c
>         > index 6561021..9d06c1e 100644
>         > --- a/net/core/dev.c
>         > +++ b/net/core/dev.c
>         > @@ -510,7 +510,7 @@ int netdev_boot_setup_check(struct
>         net_device *dev)
>         >
>         >       for (i = 0; i < NETDEV_BOOT_SETUP_MAX; i++) {
>         >               if (s[i].name[0] != '\0' && s[i].name[0] != '
>         ' &&
>         > -                 !strcmp(dev->name, s[i].name)) {
>         > +                 !strncmp(dev->name, s[i].name, IFNAMSIZ))
>         {
>         
>         
>         If s[i].name is too long, so what?  No change is required
>         here.
>         
>         >                       dev->irq        = s[i].map.irq;
>         >                       dev->base_addr  = s[i].map.base_addr;
>         >                       dev->mem_start  = s[i].map.mem_start;
>         > @@ -539,7 +539,7 @@ unsigned long netdev_boot_base(const
>         char *prefix, int unit)
>         >       char name[IFNAMSIZ];
>         >       int i;
>         >
>         > -     sprintf(name, "%s%d", prefix, unit);
>         > +     snprintf(name, IFNAMSIZ, "%s%d", prefix, unit);
>         
>         
>         This looks reasonable.
>         
>         >       /*
>         >        * If device already registered then return base of 1
>         > @@ -549,7 +549,7 @@ unsigned long netdev_boot_base(const
>         char *prefix, int unit)
>         >               return 1;
>         >
>         >       for (i = 0; i < NETDEV_BOOT_SETUP_MAX; i++)
>         > -             if (!strcmp(name, s[i].name))
>         > +             if (!strncmp(name, s[i].name, IFNAMSIZ))
>         
>         
>         Not required.
> 
>        So,  Do we have to remove already existing strncmp (to compare
> the device name)  in dev.c?
[...]

I don't know what you mean.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

