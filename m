From: Patrick McHardy <kaber@trash.net>
Subject: kfree_skb: unnecessary check ?
Date: Wed, 19 Jun 2002 18:53:18 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <3D10B6FE.1050602@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi everyone.

In skbuff.h one sees:

static inline void kfree_skb(struct sk_buff *skb)
{
        if (atomic_read(&skb->users) == 1 || 
atomic_dec_and_test(&skb->users))
                __kfree_skb(skb);
}

Is atomic_dec_and_test really necessary ? atomic_dec_and_test only 
returns true if its argument has hit zero, so it was 1 before.
If atomic_dec is only a bit cheaper than atomic_dec_and_test (which i 
guess it is), wouldn't it make more sense to use something like this:

static inline void kfree_skb(struct sk_buff *skb)
{
    if (atomic_read(&skb->users) == 1)
        __kfree(skb);
    else
        atomic_dec(&skb->users);
}

Bye,
Patrick
