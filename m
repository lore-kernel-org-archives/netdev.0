From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 22/22] usb: document that URB transfer_buffer should be
 aligned
Date: Thu, 30 Mar 2017 11:07:27 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFC2476@AcuExch.aculab.com>
References: <4f2a7480ba9a3c89e726869fddf17e31cf82b3c7.1490813422.git.mchehab@s-opensource.com>
        <1822963.cezI9HmAB6@avalon>        <1490861491.8660.2.camel@suse.com>
        <3181783.rVmBcEVlbi@avalon> <20170330072800.5ee8bc33@vento.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Oliver Neukum <oneukum@suse.com>,
        David Mosberger <davidm@egauge.net>,
        Jaejoong Kim <climbbb.kim@gmail.com>,
        Mauro Carvalho Chehab <mchehab@infradead.org>,
        Mauro Carvalho Chehab <mchehab@kernel.org>,
        "Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
        "linux-rpi-kernel@lists.infradead.org"
        <linux-rpi-kernel@lists.infradead.org>,
        Jonathan Corbet <corbet@lwn.net>,
        Wolfram Sang <wsa-dev@sang-engineering.com>,
        John Youn <johnyoun@synopsys.com>,
        Roger Quadros <rogerq@ti.com>,
        "Linux Doc Mailing List" <linux-doc@vger.kernel.org>,
        Linux Media Mailing List <linux-media@vger.kernel.org>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: 'Mauro Carvalho Chehab' <mchehab@s-opensource.com>,
        Laurent Pinchart <laurent.pinchart@ideasonboard.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.186]:58872 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932541AbdC3LHj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 07:07:39 -0400
In-Reply-To: <20170330072800.5ee8bc33@vento.lan>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mauro Carvalho Chehab
> Sent: 30 March 2017 11:28
...
> While debugging this issue, I saw *a lot* of network-generated URB
> traffic from RPi3 Ethernet port drivers that were using non-aligned
> buffers and were subject to the temporary buffer conversion.

Buffers from the network stack will almost always be 4n+2 aligned.
Receive data being fed into the network stack really needs to be
4n=2 aligned.

The USB stack almost certainly has to live with that.

If the USB ethernet device doesn't have two bytes of 'pad' before
the frame data (destination MAC address) then you have to solve
the problem within the USB stack.

For transmits it might be possible to send an initial 2 byte fragment
from a separate buffer - but only if arbitrary fragment sizes are
allowed.
A normal USB3 controller should allow this - but you have to be very
careful about what happens at the end of the ring.

	David
