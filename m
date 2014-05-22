From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: skbuff truesize incorrect.
Date: Thu, 22 May 2014 14:03:21 -0700
Message-ID: <1400792601.5367.176.camel@edumazet-glaptop2.roam.corp.google.com>
References: <537E4AFD.20304@mentor.com>
	 <1400792295.5367.174.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, kamal@canonical.com,
	Ben Hutchings <bhutchings@solarflare.com>, edumazet@google.com,
	mszeredi@suse.cz, fw@strlen.de
To: Jim Baxter <jim_baxter@mentor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400792295.5367.174.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-05-22 at 13:58 -0700, Eric Dumazet wrote:

> I would set rx_max (rx_urb_size) to SKB_MAX_HEAD(0) so that you do not
> use high order allocations.

Correction, that would need SKB_MAX_HEAD(NET_SKB_PAD + NET_IP_ALIGN),
because drivers/net/usb/usbnet.c calls __netdev_alloc_skb_ip_align().
