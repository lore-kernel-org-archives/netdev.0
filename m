From: Denis Joseph Barrow <D.Barow@option.com>
Subject: I think I figured out the another bug which manifests itself when
 low_latency is set to 0
Date: Tue, 13 Jan 2009 11:07:00 +0100
Message-ID: <496C67C4.4070501@option.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Linux USB kernel mailing list <linux-usb@vger.kernel.org>,
	Linux netdev Mailing list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.option.com ([81.246.70.163]:8104 "EHLO
	mailer2.option.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752688AbZAMKHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 05:07:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alan,
Admittedly there always was a bug when tty_insert_flip_string runs out of memory when low_latency is set to 0,

After your change I now
need a callback when tty_insert_flip_string has room for more data & I currently I don't get one,
This is needed to execute the code in hso_unthrottle_tasklet i.e. I do flow control by not submitting
read urbs to the modem when TTY_THROTTLED is set. The only way I can see for getting this callback without modifying the tty layer
is setting the TTY_THROTTLED bit if tty_insert_flip_string returns 0, I hope this works.

I'm personally a bit frightened that we may have more bugs/problems that will manifest by setting low_latency to 0,
especially for the guys here running diagnostics over the serial port requiring very high throughput.


-- 
best regards,
D.J. Barrow

Linux Kernel Developer
Option NV, Gaston Geenslaan 14, 3001 Leuven, Belgium
 
T: +32 16 311 621
F: +32 16 207 164
d.barow@option.com
www.option.com

Disclaimer:
http://www.option.com/company/disclaimer.shtml
