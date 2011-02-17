From: Chris Metcalf <cmetcalf@tilera.com>
Subject: Re: IGMP and rwlock: Dead ocurred again on TILEPro
Date: Thu, 17 Feb 2011 18:04:13 -0500
Message-ID: <4D5DA96D.5060200@tilera.com>
References: <20110217054237.GB2653@cr0.nay.redhat.com>	<20110216.214625.189707123.davem@davemloft.net>	<4D5DA60A.8080201@tilera.com> <20110217.145333.232751283.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <xiyou.wangcong@gmail.com>, <cypher.w@gmail.com>,
	<linux-kernel@vger.kernel.org>, <eric.dumazet@gmail.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110217.145333.232751283.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/17/2011 5:53 PM, David Miller wrote:
> From: Chris Metcalf <cmetcalf@tilera.com>
> Date: Thu, 17 Feb 2011 17:49:46 -0500
>
>> The fix is to disable interrupts for the arch_read_lock family of methods. 
> How does that help handle the race when it happens between different
> cpus, instead of between IRQ and non-IRQ context on the same CPU?

There's no race in that case, since the lock code properly backs off and
retries until the other cpu frees it.  The distinction here is that the
non-IRQ context is "wedged" by the IRQ context.

> Why don't you just use the generic spinlock based rwlock code on Tile,
> since that is all that your atomic instructions can handle
> sufficiently?

The tile-specific code encodes reader/writer information in the same 32-bit
word that the test-and-set instruction manipulates, so it's more efficient
both in space and time.  This may not really matter for rwlocks, since no
one cares much about them any more, but that was the motivation.

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com
