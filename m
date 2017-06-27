From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net: usb: asix88179_178a: Add support for the Belkin
 B2B128
Date: Tue, 27 Jun 2017 09:01:07 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD002BA1A@AcuExch.aculab.com>
References: <20170626174120.1293-1-afd@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "'Andrew F. Davis'" <afd@ti.com>,
        "David S . Miller" <davem@davemloft.net>,
        Allan Chou <allan@asix.com.tw>,
        Geoffrey Tran <geoffrey.tran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.192]:62489 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752445AbdF0JB2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 05:01:28 -0400
In-Reply-To: <20170626174120.1293-1-afd@ti.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew F. Davis
> Sent: 26 June 2017 18:41
> The Belkin B2B128 is a USB 3.0 Hub + Gigabit Ethernet Adapter, the
> Ethernet adapter uses the ASIX AX88179 USB 3.0 to Gigabit Ethernet
> chip supported by this driver, add the USB ID for the same.
...

I've just had a look at the current version of ax88179_178a.c.
It still makes me pull my hair out....

Not the least of the problems is that it lies about skb->truesize.
All the receive skb are longer than 16k - so will be 64k, but
it sets skb->truesize based on the actual receive frame size.

A lot of the code is also 'over complicated' - making it slower
that strictly necessary.

There is also the more general problem that usbnet is horribly
inefficient for anything trying to run at Ge speeds (never mind
anything faster.

	David
