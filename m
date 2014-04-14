From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] A panic caused by null pointer dereference aftering
 updating to
Date: Mon, 14 Apr 2014 13:34:17 -0400 (EDT)
Message-ID: <20140414.133417.308357592624654107.davem@davemloft.net>
References: <534BFC69.6080209@katalix.com>
	<CAHz2CGVVx3Fi5Vy0dr7z5r2yerbg9cjux61NM0fVeMAtK_Wf9Q@mail.gmail.com>
	<1397495549.4222.26.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nasa4836@gmail.com, jchapman@katalix.com, edumazet@google.com,
	joe@perches.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1397495549.4222.26.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 14 Apr 2014 10:12:29 -0700

> Hmm, it seems commit 31c70d5956fc l2tp: keep original skb ownership
> is the problem.
> 
> ip_queue_xmit() assumes the socket attached to skb is an inet socket.

This is similar to the "send over AF_PACKET" issue we were discussing
the other week.

It seems we need a real resolution to this issue.

To recap:

1) We want to charge memory to the top-level socket.

2) However during encapsulations etc. we can end up in IP stack
   which expects only IP sockets to be attached to skb->sk

I suspect that in the short term we may have to bit the bullet and
compromise #2, and do flow control via the tunnel's socket.
