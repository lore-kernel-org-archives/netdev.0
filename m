From: Denis Joseph Barrow <D.Barow@option.com>
Subject: a new problem with the hso driver
Date: Thu, 11 Sep 2008 17:55:33 +0200
Message-ID: <48C93F75.4000703@option.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux USB kernel mailing list <linux-usb@vger.kernel.org>,
	Linux netdev Mailing list <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Andrew Bird <ajb@spheresystems.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.option.com ([81.246.70.162]:28024 "EHLO
	mailer1.option.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752007AbYIKPzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 11:55:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Greg/Andrew,
I've a minor problem.
If you put the hso driver into powersave mode
by going into /sysfs

cd /sys/
 find . -name idVendor | xargs -n 1 | grep -H af0
 cd ./devices/pci0000:00/0000:00:1d.7/usb5/5-4/
 or wherever the idVendor is at.
 cd power/
echo auto > level

Then let the driver sleep for about 2 minutes.a

It can't be woken up, it appears that the 
usb layer is looking for a reset_resume
function to be implemented. 

We get the following messages from the kernel
[12518.790072] hso 2-2:1.0: no reset_resume for driver hso?
[12518.790081] hso 2-2:1.1: no reset_resume for driver hso?
[12518.790085] hso 2-2:1.2: no reset_resume for driver hso?

How do I implement a reset resume function?
could somebody tell me & put in a few comments in include/linux/usb.h
Our customer says the device has gone into an S3 sleep
whatever the difference between this & the reduced power mode
it goes into after 2 seconds when it calls hso_suspend I don't know.

On a slightly related issue
we get an error -22 ie -EINVAL from usb_submit_urb
this though I haven't investigated properly appears to happen when the device is suspended
but appears to have no adverse effect on the driver
it still seems to work, I haven't really investigated this, whats happening?
but would greatly appreciate being pointed in the right direction.


-- 
best regards,
D.J. Barrow
