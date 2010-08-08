From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phy: SMSC: fix unused warnings when built into kernel
Date: Sat, 07 Aug 2010 23:08:11 -0700 (PDT)
Message-ID: <20100807.230811.85439852.davem@davemloft.net>
References: <1281076034-17390-1-git-send-email-vapier@gentoo.org>
	<AANLkTi=_-ZZ8nyFLiBKSWNTcM_SkwLe2-ZL17zBQb0i4@mail.gmail.com>
	<1281099435.2088.2.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, vapier@gentoo.org, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36057
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750986Ab0HHGHw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Aug 2010 02:07:52 -0400
In-Reply-To: <1281099435.2088.2.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 06 Aug 2010 13:57:15 +0100

> On Fri, 2010-08-06 at 14:43 +0800, Changli Gao wrote:
>> On Fri, Aug 6, 2010 at 2:27 PM, Mike Frysinger <vapier@gentoo.org> wrote:
>> > If the SMSC phy is not built as a module, we get the warning:
>> >        drivers/net/phy/smsc.c:257: warning: 'smsc_tbl' defined but not used
>> >
>> > So mark the structure as maybe unused to avoid this.
>> >
>> > Signed-off-by: Mike Frysinger <vapier@gentoo.org>
>> > ---
>> >  drivers/net/phy/smsc.c |    2 +-
>> >  1 files changed, 1 insertions(+), 1 deletions(-)
>> >
>> > diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
>> > index 78fa988..11944ef 100644
>> > --- a/drivers/net/phy/smsc.c
>> > +++ b/drivers/net/phy/smsc.c
>> > @@ -254,7 +254,7 @@ MODULE_LICENSE("GPL");
>> >  module_init(smsc_init);
>> >  module_exit(smsc_exit);
>> >
>> > -static struct mdio_device_id smsc_tbl[] = {
>> > +static __maybe_unused struct mdio_device_id smsc_tbl[] = {
>> >        { 0x0007c0a0, 0xfffffff0 },
>> >        { 0x0007c0b0, 0xfffffff0 },
>> >        { 0x0007c0c0, 0xfffffff0 },
>> 
>> How about adding a #ifdef CONFIG_SMSC_PHY_MODULE clause  around these lines?
> 
> By default, gcc will discard unused variables and functions declared as
> static.  So this would not provide any run-time benefit.

We never have to do this for any other module device table, because
usually the table is actually used for the probing.

The MDIO ones are special in that they are only used for assisting in
module probing.

I would suggest that, in light of this, we make MODULE_DEVICE_TABLE()
make a dummy reference to the table.

Otherwise we're likely going going to have to add these ugly tags to
every single PHY driver.

