From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [PATCH] Handle shared SKBs in VLAN receive code
Date: Sun, 12 Oct 2003 12:00:09 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F892629.7090206@tpack.net>
References: <3F87430D.2040000@tpack.net>	<3F87464B.1020908@candelatech.com>	<3F874A30.6010700@tpack.net>	<3F885418.3090407@candelatech.com> <20031011120339.0da631e6.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

> The current code is correct and handles shared SKBs properly,
> so I don't think it's worth playing around with this much more.

No, it is still not right.

Bear with me, but this is how I understand it:

  - The sk_buff *structure* is read-only on a shared SKB.
    skb_share_check(skb) breaks the sharing, thus allowing
    updates of skb->dev, skb->len etc.
    But the SKB still points at the same data buffer.

  - The *data* buffer is read-only on a cloned SKB.
    skb_cow() or skb_copy() or ... gives us a writeable buffer.

The tcpdump problem was caused by violating the second rule,
this is now fixed.

But the code still doesn't follow the first rule, which is
what this patch fixes.


-Tommy
