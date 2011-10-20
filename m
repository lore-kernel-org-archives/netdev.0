From: David Miller <davem@davemloft.net>
Subject: Re: Kernel panic from tg3 net driver
Date: Thu, 20 Oct 2011 15:56:59 -0400 (EDT)
Message-ID: <20111020.155659.486754557434415381.davem@davemloft.net>
References: <CAEbykaXz+J8abVzU3yjqZG2+yhHNrQWsQy2c8wNyoERWPpxWKQ@mail.gmail.com>
	<CAEbykaX4UPDBxOHmNr=dodaquSPjhPr-pLCcUn5hSu4-xLZy-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ari.m.savolainen@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEbykaX4UPDBxOHmNr=dodaquSPjhPr-pLCcUn5hSu4-xLZy-g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ari Savolainen <ari.m.savolainen@gmail.com>
Date: Thu, 20 Oct 2011 22:30:44 +0300

> I finally got time to continue bisecting. The commit that causes the
> kernel panic is:  2669069aacc9 "tg3: enable transmit time stamping."

I thought initially that the issue might be that we have to do the
skb_tx_timestamp() call before we advance the mailbox transmit
descriptor pointer.

But that shouldn't matter, we run with a lock held, and TX reclaim takes
that same lock.

So I'm sort of stumped at the moment.
