From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] phy: SMSC: fix unused warnings when built into kernel
Date: Fri, 06 Aug 2010 13:57:15 +0100
Message-ID: <1281099435.2088.2.camel@achroite.uk.solarflarecom.com>
References: <1281076034-17390-1-git-send-email-vapier@gentoo.org>
	 <AANLkTi=_-ZZ8nyFLiBKSWNTcM_SkwLe2-ZL17zBQb0i4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Mike Frysinger <vapier@gentoo.org>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:15108 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760882Ab0HFM5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Aug 2010 08:57:19 -0400
In-Reply-To: <AANLkTi=_-ZZ8nyFLiBKSWNTcM_SkwLe2-ZL17zBQb0i4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-08-06 at 14:43 +0800, Changli Gao wrote:
> On Fri, Aug 6, 2010 at 2:27 PM, Mike Frysinger <vapier@gentoo.org> wrote:
> > If the SMSC phy is not built as a module, we get the warning:
> >        drivers/net/phy/smsc.c:257: warning: 'smsc_tbl' defined but not used
> >
> > So mark the structure as maybe unused to avoid this.
> >
> > Signed-off-by: Mike Frysinger <vapier@gentoo.org>
> > ---
> >  drivers/net/phy/smsc.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> >
> > diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
> > index 78fa988..11944ef 100644
> > --- a/drivers/net/phy/smsc.c
> > +++ b/drivers/net/phy/smsc.c
> > @@ -254,7 +254,7 @@ MODULE_LICENSE("GPL");
> >  module_init(smsc_init);
> >  module_exit(smsc_exit);
> >
> > -static struct mdio_device_id smsc_tbl[] = {
> > +static __maybe_unused struct mdio_device_id smsc_tbl[] = {
> >        { 0x0007c0a0, 0xfffffff0 },
> >        { 0x0007c0b0, 0xfffffff0 },
> >        { 0x0007c0c0, 0xfffffff0 },
> 
> How about adding a #ifdef CONFIG_SMSC_PHY_MODULE clause  around these lines?

By default, gcc will discard unused variables and functions declared as
static.  So this would not provide any run-time benefit.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

