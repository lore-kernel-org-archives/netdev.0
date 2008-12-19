From: Denis Joseph Barrow <D.Barow@option.com>
Subject: Re: another race in hso
Date: Fri, 19 Dec 2008 12:06:35 +0100
Message-ID: <494B803B.9000703@option.com>
References: <200812191145.31556.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: ajb@spheresystems.co.uk, Greg Kroah-Hartman <greg@kroah.com>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Oliver Neukum <oliver@neukum.org>, schwidefsky@de.ibm.com,
	strasse@de.ibm.com, Paul Hardwick <P.Hardwick@option.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.option.com ([81.246.70.163]:60064 "EHLO
	mailer2.option.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751471AbYLSLHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2008 06:07:04 -0500
In-Reply-To: <200812191145.31556.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes Oliver,
There are loads of races in the hso driver it's as ugly as sin.
I've been doing nothing but blocking holes not eliminating races which probably
would require a serious redesign & I don't have the clarity of thought like martin schwidefsky
to do it.
There were almost none in my lcs driver though martin didn't believe me & had to rewrite it.
Get Martin Schwidefsky to look over it.
I hope he needs to write a 3g modem driver for linux on the z series anyway
so he may as well get used to the code.


Oliver Neukum wrote:
> Hi,
> 
> there is another race.
> 
> static int hso_get_activity(struct hso_device *hso_dev)
> {
> 	if (hso_dev->usb->state == USB_STATE_SUSPENDED) {
> 		if (!hso_dev->is_active) {
> 			hso_dev->is_active = 1;
> 			schedule_work(&hso_dev->async_get_intf);
> 		}
> 	}
> 
> 	if (hso_dev->usb->state != USB_STATE_CONFIGURED)
> 		return -EAGAIN;
> 
> here's the window.
> 
> 	usb_mark_last_busy(hso_dev->usb);
> 
> 	return 0;
> }
> 
> CPU A							CPU B
> 
> run until the window
> 								autosuspend of device
> submitting URB to suspended device
> 
> You get an unnecessary error.
> 
> 	Regards
> 		Oliver


-- 
best regards,
D.J. Barrow

Linux Kernel Developer
Option NV, Gaston Geenslaan 14, 3001 Leuven, Belgium
 
T: +32 16 311 621
F: +32 16 207 164
Mobile Ireland: +353-86-1715438
Mobile Belgium  +32-496-226190
d.barow@option.com
barrow_dj@yahoo.com
www.option.com
www.travelsmart.ie

Disclaimer:
http://www.option.com/company/disclaimer.shtml
 RPR Leuven 0429.375.448
