From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: skbuff truesize incorrect.
Date: Thu, 22 May 2014 13:58:15 -0700
Message-ID: <1400792295.5367.174.camel@edumazet-glaptop2.roam.corp.google.com>
References: <537E4AFD.20304@mentor.com>
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
In-Reply-To: <537E4AFD.20304@mentor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-05-22 at 20:07 +0100, Jim Baxter wrote:

> 
> I have been investigating a network issue with bursts of network traffic
> over USB CDC-NCM, the issue is that the kernel is dropping packets
> because sk_rcvqueues_full() returns true due to skb2->truesize is always
> 32960 instead of SKB_TRUESIZE(skb2->len) which is about 1800.
> 
> The code I am trying to fix is this code below, it is splitting a set of
> multiple network packets compressed into a single 16k packet into
> individual skb's and sending them up the network stack.

if skb are allocated with 16k = 16384 bytes, adding the struct
skb_shared_info overhead and rounding up to power of two gives 32768
bytes.

Chances to be able to allocate 32KB contiguous memory are slim after a
while.

I would set rx_max (rx_urb_size) to SKB_MAX_HEAD(0) so that you do not
use high order allocations.

What is the exact 'overhead' using ~4K instead of 16K exactly on this
hardware ?
