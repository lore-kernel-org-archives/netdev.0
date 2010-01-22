From: Marcel Holtmann <marcel@holtmann.org>
Subject: RE: [PATCH net-next-2.6 13/13] net-caif-driver: add CAIF serial
 driver (ldisc)
Date: Fri, 22 Jan 2010 11:07:05 +0100
Message-ID: <1264154825.3469.35.camel@violet>
References: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com>
	 <1264028130-14364-14-git-send-email-sjur.brandeland@stericsson.com>
	 <1264152116.3469.18.camel@violet>
	 <61D8D34BB13CFE408D154529C120E07903232089@eseldmw101.eemea.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stefano.babic@babic.homelinux.org, randy.dunlap@oracle.com
To: Sjur =?ISO-8859-1?Q?Br=E6ndeland?=
	<sjur.brandeland@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:36727 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750985Ab0AVKGE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 05:06:04 -0500
In-Reply-To: <61D8D34BB13CFE408D154529C120E07903232089@eseldmw101.eemea.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sjur,

> >> Add CAIF Serial driver. This driver is implemented as a line
> >> discipline. The TTY is opened from inside the kernel module.
> >> 
> >> caif_serial uses the following module parameters:
> >> ser_ttyname - specifies the tty name.
> >> ser_use_stx - specifies if STart of frame eXtension is in use.
> >> ser_loop    - sets the interface in loopback mode.
> > 
> > I think opening the TTY from within the kernel is the wrong approach.
> > It basically takes all the control away from the system people trying
> > to bring up the device. And for every special TTY you need to add
> > hacks and workarounds.   
> > 
> > You should be just providing the TTY line discipline for CAIF. And
> > then have a program like caifattach that open the TTY and sets it. We
> > do this for Bluetooth with hciattach for IrDA with irattach etc.  
> 
> I see your point, actually we did this in a while back, 
> but changed it to open the tty from kernel side.
> I think this is a trade off between flexibility and making it simple to 
> use from user space. Another problem with the current approach miss the
> flexibility of configuring the UART and the possibility to have multiple 
> serial links...

that is why am I proposing just providing the line discipline and an
extra caifattach program.

With that we can add some plugin to oFono that just does the same as
caifattach would do and get a really smooth integration for embedded
platform, but on the other hand enough flexibility for everything else.

For Bluetooth and IrDA this approach has been working nicely for years
now.

Regards

Marcel


