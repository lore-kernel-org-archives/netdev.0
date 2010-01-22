From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH net-next-2.6 13/13] net-caif-driver: add CAIF serial
 driver (ldisc)
Date: Fri, 22 Jan 2010 10:21:56 +0100
Message-ID: <1264152116.3469.18.camel@violet>
References: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com>
	 <1264028130-14364-14-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stefano.babic@babic.homelinux.org, randy.dunlap@oracle.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:43969 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752917Ab0AVJUz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 04:20:55 -0500
In-Reply-To: <1264028130-14364-14-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sjur,

> Add CAIF Serial driver. This driver is implemented as a line discipline.
> The TTY is opened from inside the kernel module.
> 
> caif_serial uses the following module parameters:
> ser_ttyname - specifies the tty name.
> ser_use_stx - specifies if STart of frame eXtension is in use.
> ser_loop    - sets the interface in loopback mode.

I think opening the TTY from within the kernel is the wrong approach. It
basically takes all the control away from the system people trying to
bring up the device. And for every special TTY you need to add hacks and
workarounds.

You should be just providing the TTY line discipline for CAIF. And then
have a program like caifattach that open the TTY and sets it. We do this
for Bluetooth with hciattach for IrDA with irattach etc.

Regards

Marcel


