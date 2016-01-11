From: Zang MingJie <zealot0630@gmail.com>
Subject: Re: [PATCH] net: preserve IP control block during GSO segmentation
Date: Mon, 11 Jan 2016 15:45:57 +0800
Message-ID: <56935DB5.1030502__26500.4228837372$1452499525$gmane$org@gmail.com>
References: <145225444176.22215.2003378381077166898.stgit@zurg>
 <063D6719AE5E284EB5DD2968C1650D6D1CCC01BA@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dev@openvswitch.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:36594 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758602AbcAKIFG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jan 2016 03:05:06 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1aIXTK-0000xW-Q9
	for netdev@vger.kernel.org; Mon, 11 Jan 2016 09:05:03 +0100
Received: from li414-6.members.linode.com ([106.187.94.6])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 09:05:02 +0100
Received: from zealot0630 by li414-6.members.linode.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 09:05:02 +0100
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CCC01BA@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/08/2016 08:13 PM, David Laight wrote:
> You could set SKB_SGO_CB_OFFSET to sizeof ((skb)->cb) - sizeof (struct skb_gso_cb)
> so that the end of 'cb' is always used.
> (Assuming the former is a multiple of 4.)
>
> It might be worth using an on-stack structure passed through as a separate
> parameter - it doesn't look as though it has to be queued with the skb.
> (Clearly a bigger change.)

I would definitely prefer the stack structure.

As a kernel developer, sometime I can hardly figure out which struct 
current cb is without debug it, and the worst they are not documented 
anywhere. I can hardly know the life time of the cb types.

If using a stack, things can be much easier. only an extra var to store 
the stack top:

    int cb_top;

and several macro to manage the stack:

    SKB_CB_PUSH(skb, type)
    SKB_CB_POP(skb)
    SKB_CB_TOP(skb, type)

and maybe a debug variable to store current cb type.

All current cb macro can be replaced by SKB_CB_TOP.


Although it is a big change, I think it worths, for both performance and 
maintainability
