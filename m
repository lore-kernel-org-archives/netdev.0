From: David Miller <davem@davemloft.net>
Subject: Re: BUG: net/netfilter: KASAN: stack-out-of-bounds in tcp_packet
Date: Mon, 28 Mar 2016 19:54:57 -0400 (EDT)
Message-ID: <20160328.195457.1407210954449940457.davem@davemloft.net>
References: <alpine.LSU.2.20.1603282214130.16241@nerf40.vanv.qr>
	<1459197963.6473.125.camel@edumazet-glaptop3.roam.corp.google.com>
	<1459198306.6473.126.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jengelh@inai.de, kadlec@blackhole.kfki.hu, sploving1@gmail.com,
	pablo@netfilter.org, kaber@trash.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1459198306.6473.126.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 28 Mar 2016 13:51:46 -0700

> On Mon, 2016-03-28 at 13:46 -0700, Eric Dumazet wrote:
> 
>> We have at least 384 bytes of padding in skb->head (this is struct
>> skb_shared_info).
>> 
>> Whatever garbage we might read, current code is fine.
>> 
>> We have to deal with a false positive here.
> 
> Very similar to the one fixed in 
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=10ec9472f05b45c94db3c854d22581a20b97db41

I don't see them as similar.

The current options code we are talking about here never references
past legitimate parts of the packet data.  We always check 'length',
and we never access past the boundary it describes.

This was the entire point of my posting.

Talking about padding, rather than the logical correctness of the
code, is therefore a distraction I think :-)
