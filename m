From: Andreas Leitgeb <avl@logic.at>
Subject: IrDA spams logfiles - since 2.6.19
Date: Sun, 7 Jan 2007 01:51:50 +0100
Message-ID: <20070107005150.GE22817@gamma.logic.tuwien.ac.at>
Reply-To: avl@logic.at
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.logic.tuwien.ac.at ([128.130.175.20]:50051 "EHLO
	alpha.logic.tuwien.ac.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932300AbXAGBWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Jan 2007 20:22:44 -0500
Received: from gamma.logic.tuwien.ac.at ([128.130.175.3])
	by alpha.logic.tuwien.ac.at with esmtp (Exim 3.35 #1)
	id 1H3MGN-000440-00
	for netdev@vger.kernel.org; Sun, 07 Jan 2007 01:51:51 +0100
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm not on this list, so please keep me CC'ed on this thread.

Since 2.6.19 I've got a problem with my Tekram IRmate 410U 
usb-irda-dongle. Until 2.6.18.3 (the latest I had before 2.6.19*)
it worked just fine.  2.6.19.1 had another change in irda-usb
but that didn't solve the problem.

As soon as I load the irda-usb module with the device plugged,
I get lots of messages of following kind into the logs:
  irda_usb_hard_xmit(), Insuficient skb headroom.
(the "Insuficient"-typo is original)
about 7 in a second, then a 2-secs pause. Repeating 
until the irda-usb module is removed again.

I then looked up the kernel-source for that particular 
typo'ed word, and added some info to the log:
  drivers/net/irda/irda-usb.c:448:
        if (skb_headroom(skb) < self->header_length) {
                IRDA_DEBUG(0, "%s(), Insuficient skb headroom. %d / %d \n",
                     __FUNCTION__, skb_headroom(skb) , self->header_length);
        ...
Which came out as:
  irda_usb_hard_xmit(), Insuficient skb headroom. 0 / 1
Thus, while self->header_length == USB_IRDA_HEADER,
I didn't yet understand the meaning of fields
  ->data and ->head of the skb.

I don't know, if the warning itself is right or wrong,
because other than the spamming of logs, transferring
data over irda appears to work just fine.

(I've got timestamps turned on, so usual repeat-compression
by syslogd doesn't take effect.)

