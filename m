From: Andy Fleming <afleming@gmail.com>
Subject: Re: SMSC 8720a/MDIO/PHY help.
Date: Fri, 15 Apr 2011 15:36:24 -0500
Message-ID: <BANLkTik9_F10sP7t7beDfULc3AwZ6ycU-A@mail.gmail.com>
References: <9AC3F0E75060224C8BBC5BA2DDC8853A1FA8E632@EXV1.corp.adtran.com>
	<1302729564.2742.28.camel@malcolm>
	<9AC3F0E75060224C8BBC5BA2DDC8853A1FA8E8D4@EXV1.corp.adtran.com>
	<9AC3F0E75060224C8BBC5BA2DDC8853A1FA8E8FD@EXV1.corp.adtran.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ANDY KENNEDY <ANDY.KENNEDY@adtran.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:61316 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751025Ab1DOUgY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 16:36:24 -0400
Received: by pwi15 with SMTP id 15so1266624pwi.19
        for <netdev@vger.kernel.org>; Fri, 15 Apr 2011 13:36:24 -0700 (PDT)
In-Reply-To: <9AC3F0E75060224C8BBC5BA2DDC8853A1FA8E8FD@EXV1.corp.adtran.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 13, 2011 at 11:08 PM, ANDY KENNEDY <ANDY.KENNEDY@adtran.com=
> wrote:
>> > -----Original Message-----
>> > From: Michael Riesch [mailto:michael@riesch.at]
>> > Sent: Wednesday, April 13, 2011 4:19 PM
>> > To: netdev@vger.kernel.org
>> > Cc: ANDY KENNEDY
>> > Subject: Re: SMSC 8720a/MDIO/PHY help.
>> >
>> >
>> > > If you have an idea of something for me to try, I'd love to
>> > entertain
>> > > it.
>> >
>> > I am rather new to PHYLIB, but these are my ideas:
>> >
>> > =A01) make sure phy_connect is executed (AFIAK called by MDIO bus
>> > driver)
>
> Along this line of though: =A0phy_connect requires struct net_device,=
 which has a struct net_device_ops within it. =A0When I do a phy_connec=
t am I supposed to provide the minimal functions for netdev_ops (correc=
t this list if I am mistaken):
> ndo_open
> ndo_stop
> ndo_start_xmit
> ndo_get_stats
> ndo_set_multicast_list
> As well as populate the dev->dev_addr within the struct net_device.
>
> The part that confuses me is that the smsc.c ??driver?? under drivers=
/net/phy/smsc.c doesn=92t do any of this. =A0This is a phy supported by=
 this file, so should I have to do all this to get the device up?


Hmm....where are you calling phy_connect from?  phy_connect() is
called from a net_device driver, to connect the net device to the PHY.
The net_device should be filled in by the net driver. The PHY Lib
doesn't use the struct net_device * itself.  It merely passes that
structure to the registered adjust_link() callback, as context.

We could theoretically make the net_device a void *, and let the
caller of phy_connect() determine its own context, but that didn't
seem necessary at the time.  It also might make sense for
adjust_link() to pass the struct phy_device.

But those are all just possible enhancements for the future.

Andy
