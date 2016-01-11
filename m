From: Zang MingJie <zealot0630@gmail.com>
Subject: Re: [PATCH] net: preserve IP control block during GSO segmentation
Date: Mon, 11 Jan 2016 15:45:57 +0800
Message-ID: <56935DB5.1030502__33886.0177122571$1452499833$gmane$org@gmail.com>
References: <145225444176.22215.2003378381077166898.stgit@zurg>
 <063D6719AE5E284EB5DD2968C1650D6D1CCC01BA@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dev@openvswitch.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CCC01BA@AcuExch.aculab.com>
Cc: dev@openvswitch.org, linux-kernel@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
