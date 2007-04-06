From: Stephan Helas <shelas@web.de>
Subject: Re: Fw: kernel oops at ppp
Date: Fri, 06 Apr 2007 22:33:58 +0200
Message-ID: <4616AEB6.3080607@web.de>
References: <20070331121633.858312f1.akpm@linux-foundation.org> <17935.6115.518506.249844@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org
To: Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate03.web.de ([217.72.192.234]:58347 "EHLO
	fmmailgate03.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932854AbXDFUeF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2007 16:34:05 -0400
In-Reply-To: <17935.6115.518506.249844@cargo.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>Paul Mackerras wrote:
> What is a "UMTS - hsdpa card merlin xu870"?


It is a Novatel Wireless Card, using usb-serial driver airprime

http://www.novatelwireless.com/support/merlin-xu870-linux.html


> At a guess I would say that whatever ppp channel code is being used
> hasn't left any header room on a received skb, but without knowing
> what ppp channel module is being used it's hard to say.
> 
> Paul.

After some Experiments with 2.6.21-rc (2.6.20 crash with airprime on
boot), i belive its the wrong driver. To enable Support for this Card i
added the pci-device string to airprime.c

--------- drivers/usb/serial/airprime.c -----------

static struct usb_device_id id_table [] = {
 { USB_DEVICE(0x0c88, 0x17da) }, /* Kyocera Wireless KPC650/Passport */
 { USB_DEVICE(0x413c, 0x8115) }, /* Dell Wireless HSDPA 5500 */
 ^^^^^^^^^^^
 { USB_DEVICE(0x1410, 0x1430) }, /* Novatel Wireless Merlin XU870 */
 { },
};

--------- drivers/usb/serial/airprime.c -----------


After reading some Information about option.c, i saerch and found the
Device-String in option.c

After Loading this Modul, the card works now for me.



Best Regards and Great Thx for helping me
Stephan

