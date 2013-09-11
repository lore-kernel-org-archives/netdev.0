From: "David Laight" <David.Laight@ACULAB.COM>
Subject: usbnet transmit scatter-gather
Date: Wed, 11 Sep 2013 14:19:24 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7328@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:57040 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753421Ab3IKNUo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 09:20:44 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 03818-01 for <netdev@vger.kernel.org>;
 Wed, 11 Sep 2013 14:20:41 +0100 (BST)
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

usbnet and ax88179_178a.c where changed fairly recently to support
scatter-gather transmit.
(This would let TSO be re-enabled.)

The change removed the skb_serialize() from ax88179_178a.c.
This means that things will go horribly wrong if the hardware
doesn't support SG (my i7 box must support SG), I'm sure
I can find something that doesn't :-)

I think the interface to usbnet needs changing so that:
1) The driver reports whether it can process segmented skb.
2) If the driver can't process segmented skb, usbnet will
   call skb_serialize() prior to calling tx_fixup().
3) If the usb hardware can't do SG, usbnet will call
   skb_serialize() after calling tx_fixup().

Would it make sense for usbnet mask out TSO support
when SG dma is unavailable?

	David
