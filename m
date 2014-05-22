From: David Miller <davem@davemloft.net>
Subject: Re: skbuff truesize incorrect.
Date: Thu, 22 May 2014 17:10:33 -0400 (EDT)
Message-ID: <20140522.171033.1040508444998374401.davem@davemloft.net>
References: <537E4AFD.20304@mentor.com>
	<1400792295.5367.174.camel@edumazet-glaptop2.roam.corp.google.com>
	<1400792601.5367.176.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jim_baxter@mentor.com, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kamal@canonical.com, bhutchings@solarflare.com,
	edumazet@google.com, mszeredi@suse.cz, fw@strlen.de, bjorn@mork.no
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400792601.5367.176.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 22 May 2014 14:03:21 -0700

> On Thu, 2014-05-22 at 13:58 -0700, Eric Dumazet wrote:
> 
>> I would set rx_max (rx_urb_size) to SKB_MAX_HEAD(0) so that you do not
>> use high order allocations.
> 
> Correction, that would need SKB_MAX_HEAD(NET_SKB_PAD + NET_IP_ALIGN),
> because drivers/net/usb/usbnet.c calls __netdev_alloc_skb_ip_align().

I seem to recall that this driver has a lot of strange buffering
restrictions and that Bjorn Mork was talking a lot about this
recently.

Bjorn people are getting really burnt because the driver ends up
having a skb->truesize of 32K for the buffers it allocates on receive
and this chokes up TCP and SCTP because the socket memory limits
are hitting earlier than they should.

We've just in the past few postings been discussing whether the just
copy every packet into a more appropriately sized buffer, and it isn't
clear if that's a good idea of the data rates handled here.
