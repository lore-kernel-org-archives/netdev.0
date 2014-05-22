From: David Miller <davem@davemloft.net>
Subject: Re: skbuff truesize incorrect.
Date: Thu, 22 May 2014 15:21:46 -0400 (EDT)
Message-ID: <20140522.152146.2116142050088142989.davem@davemloft.net>
References: <537E4AFD.20304@mentor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, kamal@canonical.com,
	bhutchings@solarflare.com, edumazet@google.com, mszeredi@suse.cz,
	fw@strlen.de
To: jim_baxter@mentor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <537E4AFD.20304@mentor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jim Baxter <jim_baxter@mentor.com>
Date: Thu, 22 May 2014 20:07:41 +0100

> My questions are:
> 
> 1) Which buffer size does truesize represent, is it the total buffer or
> just the data related to the relevant skb?
> 
> 2) If truesize is for the skb it is contained within should it be
> updated during the call to skb_trim?
> 
> 3) Why does the truesize default to 32960?

skb->truesize represents the total amount of memory that the SKB
is holding up.

This is the size of the sk_buff metadata plus all of the buffer
memory.

For example, if the buffer is using 16K buffer yet only 1500 of it is
actually used for the packet, 16K is what should be plugged into the
equation to compute truesize.

Otherwise it would be easy to compromise a system by sending lots of 1
byte packets to a socket, even though the actual memory consumed by
that "1 byte" packet is significantly larger.
