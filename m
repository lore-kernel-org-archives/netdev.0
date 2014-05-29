From: Jim Baxter <jim_baxter@mentor.com>
Subject: [PATCH v1 0/3] usb: gadget: NCM: Fixes and Multi-frame for TX.
Date: Thu, 29 May 2014 18:12:20 +0100
Message-ID: <1401383543-10181-1-git-send-email-jim_baxter@mentor.com>
References: <Jim Baxter <jim_baxter@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	<linux-usb@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Laight <David.Laight@ACULAB.COM>,
	<netdev@vger.kernel.org>
To: Felipe Balbi <balbi@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Jim Baxter <jim_baxter@mentor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series adds the ability to support packaging multiple network
packets into a single 16k CDC-NCM NTB.

Patches 1 and 3 are fixes for the receive unwrap function which
previously was unable to handle an NTB with multiple NDP's and a fix
that switches from using skb_clone to creating a new packet to fix the
issue of the truesize being far to big and causing packets to be
dropped incorrectly.

Jim Baxter (3):
  usb: gadget: NCM: RX function support multiple NDPs
  usb: gadget: NCM: Add transmit multi-frame.
  usb: gadget: NCM: Stop RX TCP Bursts getting dropped.

 drivers/usb/gadget/f_ncm.c   |  480 +++++++++++++++++++++++++++++-------------
 drivers/usb/gadget/u_ether.c |   19 +-
 drivers/usb/gadget/u_ether.h |    2 +
 3 files changed, 347 insertions(+), 154 deletions(-)

-- 
1.7.9.5
