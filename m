From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next 2/2] r8152: adjust rtl_start_rx
Date: Mon, 10 Nov 2014 03:29:27 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2ECE0A3@RTITMBSV03.realtek.com.tw>
References: <1394712342-15778-88-Taiwan-albertk@realtek.com>
	<1394712342-15778-90-Taiwan-albertk@realtek.com>
 <20141107.113522.837502028522211960.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:52547 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751329AbaKJD3f convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Nov 2014 22:29:35 -0500
In-Reply-To: <20141107.113522.837502028522211960.davem@davemloft.net>
Content-Language: zh-TW
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 David Miller [mailto:davem@davemloft.net] 
> Sent: Saturday, November 08, 2014 12:35 AM
[...]
> Does this even work?
> 
> If you leave a hole in the ring, the device is going to stop there
> anyways.

Excuse me. I don't sure I understand your meaning clearly.

The behavior is different for PCI(e) and USB ethernet device.
The PCI nic could know the ring buffer by certain way, so
the device could fill the data into the buffer one by one
automatically. However, for usb nic, the driver has to
indicate (i.e. submit) each buffer for each data. The device
doesn't know what is the next buffer by itself. That is,
the driver determines the order by which the data would be
filled.

Therefore, when I try to submit 10 rx buffers and some of
them fail, I could get the data depending on the order of
the successful ones. Besides, the driver has to submit the
buffer for next data continually, so the previous unsuccessful
ones could be tried again for the same time.
 
Best Regards,
Hayes
