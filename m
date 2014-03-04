From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 08/12] r8152: support TSO
Date: Tue, 4 Mar 2014 12:11:44 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6CFFE0@AcuExch.aculab.com>
References: <1393934464-23675-1-git-send-email-hayeswang@realtek.com>
 <1393934464-23675-9-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "nic_swsd@realtek.com" <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: 'Hayes Wang' <hayeswang@realtek.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393934464-23675-9-git-send-email-hayeswang@realtek.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang
> Support scatter gather and TSO.
> 
> Adjust the tx checksum function and set the max gso size to fix the
> size of the tx aggregation buffer.

There is little point supporting TSO unless the usb host controller
supports arbitrary aligned scatter-gather.
All you do is require that a large skb be allocated (that may well
fail), and add it another data copy.

The xhci controller is almost capable of arbitrary scatter-gather,
but it is currently disabled because the data must be aligned at
the end of the transfer ring (the hardware designers have made it
almost impossible to write efficient software).

Note that the various xhci controllers behave subtly differently.

	David
