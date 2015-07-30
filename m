From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ARCNET: fix hard_header_len limit
Date: Thu, 30 Jul 2015 11:16:36 -0700 (PDT)
Message-ID: <20150730.111636.2181952489319443707.davem@davemloft.net>
References: <1438263276-26202-1-git-send-email-m.grzeschik@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@pengutronix.de
To: m.grzeschik@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438263276-26202-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Date: Thu, 30 Jul 2015 15:34:36 +0200

> The commit <9c7077622dd9> ("packet: make packet_snd fail on len smaller
> than l2 header") adds the check for minimum packet length of the used l2.
> For arcnet the hardware header length is not the complete archdr which
> includes hard + soft header. This patch changes the length to
> sizeof(arc_hardware).
> 
> Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>

The hard header len is used for other purposes as well, are you sure
those don't get broken by this change?

Code assumes that if the data at the SKB mac pointer is taken, for
dev->hard_header_len bytes, that is exactly the link layer header.
And that this can be used to compare two MAC headers, copy the
MAC header from one packet to another, etc.
