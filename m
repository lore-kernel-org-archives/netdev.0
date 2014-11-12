From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next 2/2] r8152: adjust rtl_start_rx
Date: Wed, 12 Nov 2014 06:29:46 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2ECE46C@RTITMBSV03.realtek.com.tw>
References: <0835B3720019904CB8F7AA43166CEEB2ECE429@RTITMBSV03.realtek.com.tw>
	<20141112.001318.1905417679166281362.davem@davemloft.net>
	<0835B3720019904CB8F7AA43166CEEB2ECE442@RTITMBSV03.realtek.com.tw>
 <20141112.004331.1112374574697663525.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:35979 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752538AbaKLGcj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 01:32:39 -0500
In-Reply-To: <20141112.004331.1112374574697663525.davem@davemloft.net>
Content-Language: zh-TW
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller [mailto:davem@davemloft.net] 
> Sent: Wednesday, November 12, 2014 1:44 PM
[...]
> What do other USB network drivers do in similar situations?

According to the usbnet.c, it would make sure to submit the
number of min(10, RX_QLEN(dev)) rx buffers. If there are
not enough rx buffers, it schedule a tasklet for next try.

The brief flow is as following.
1. Call open().
   - schedule a tasklet.
2. Tasklet is called.
   if (dev->rxq.qlen < RX_QLEN(dev)) {
	   - submit rx buffers util the number of
	     min(10, RX_QLEN(dev)). If the error
	     occurs, break the loop.
	   - If the dev->rxq.qlen < RX_QLEN(dev),
	     schedule the tasklet.
   }

Best Regards,
Hayes
