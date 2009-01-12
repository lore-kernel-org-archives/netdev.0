From: Denis Joseph Barrow <D.Barow@option.com>
Subject: re your change to the low_latency flag in the hso driver in 2.6.29-rc1
Date: Mon, 12 Jan 2009 18:23:53 +0100
Message-ID: <496B7CA9.6080403@option.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux USB kernel mailing list <linux-usb@vger.kernel.org>,
	Linux netdev Mailing list <netdev@vger.kernel.org>,
	Paul Hardwick <P.Hardwick@option.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.option.com ([81.246.70.162]:57422 "EHLO
	mailer1.option.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751853AbZALRX5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 12:23:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alan,
I remember removing the low_latency flag to 0 once & if I recall correctly performance 
was severely impacted & there may have been other problems which I don't recall.
even worse I believe the code can now hang the kernel, the fix is simple, in
put_rxbuf_data I'm dependent on the TTY_THROTTLED bit to exit the loop.
Now tty_insert_flip_string can return 0 bytes leading to an infinite loop if tty buffers are full,
as write_length_remaining never goes to zero as I am dependent on the line
discipline being called from tty_flip_buffer_push to set TTY_THROTTLED by calling flush_to_ldisc
checking if curr_write_len=0 from tty_insert_flip_string might fix the problem
Please look at put_rxbuf_data carefully, there might be other gremlins. The serial port
is supposed to be high performance this fix will impact this

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
