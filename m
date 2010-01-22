From: =?iso-8859-1?Q?Sjur_Br=E6ndeland?= <sjur.brandeland@stericsson.com>
Subject: RE: [PATCH net-next-2.6 13/13] net-caif-driver: add CAIF serial driver (ldisc)
Date: Fri, 22 Jan 2010 10:56:20 +0100
Message-ID: <61D8D34BB13CFE408D154529C120E07903232089@eseldmw101.eemea.ericsson.se>
References: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com> <1264028130-14364-14-git-send-email-sjur.brandeland@stericsson.com> <1264152116.3469.18.camel@violet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<stefano.babic@babic.homelinux.org>, <randy.dunlap@oracle.com>
To: "Marcel Holtmann" <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw5.ericsson.se ([193.180.251.36]:51174 "EHLO
	mailgw5.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752992Ab0AVJ4Z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 04:56:25 -0500
Content-class: urn:content-classes:message
In-Reply-To: <1264152116.3469.18.camel@violet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marcel Holtmann wrote:
> Hi Sjur,
> 
>> Add CAIF Serial driver. This driver is implemented as a line
>> discipline. The TTY is opened from inside the kernel module.
>> 
>> caif_serial uses the following module parameters:
>> ser_ttyname - specifies the tty name.
>> ser_use_stx - specifies if STart of frame eXtension is in use.
>> ser_loop    - sets the interface in loopback mode.
> 
> I think opening the TTY from within the kernel is the wrong approach.
> It basically takes all the control away from the system people trying
> to bring up the device. And for every special TTY you need to add
> hacks and workarounds.   
> 
> You should be just providing the TTY line discipline for CAIF. And
> then have a program like caifattach that open the TTY and sets it. We
> do this for Bluetooth with hciattach for IrDA with irattach etc.  

I see your point, actually we did this in a while back, 
but changed it to open the tty from kernel side.
I think this is a trade off between flexibility and making it simple to 
use from user space. Another problem with the current approach miss the
flexibility of configuring the UART and the possibility to have multiple 
serial links...

BR/Sjur
