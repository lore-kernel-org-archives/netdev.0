From: kuznet@ms2.inr.ac.ru
Subject: Re: kfree_skb: unnecessary check ?
Date: Thu, 20 Jun 2002 00:26:30 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200206192026.AAA17502@sex.inr.ac.ru>
References: <3D10B6FE.1050602@trash.net>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: kaber@trash.NET (Patrick McHardy)
In-Reply-To: <3D10B6FE.1050602@trash.net> from "Patrick McHardy" at Jun 19, 2 09:15:00 pm
List-Id: netdev.vger.kernel.org

Hello!

> Is atomic_dec_and_test really necessary ? atomic_dec_and_test only 
> returns true if its argument has hit zero, so it was 1 before.
> If atomic_dec is only a bit cheaper than atomic_dec_and_test (which i 
> guess it is), wouldn't it make more sense to use something like this:

Does the prefix "atomic" not scare you? :-)


> static inline void kfree_skb(struct sk_buff *skb)
> {
>     if (atomic_read(&skb->users) == 1)
>         __kfree(skb);
>     else
>         atomic_dec(&skb->users);
> }

      else if (atomic_dec_and_test(&skb->users))
	   __kfree_skb(skb);

If you still do not understand think why it does not look like:

static inline void kfree_skb(struct sk_buff *skb)
{
    int users = skb->users;
    if (users == 1)
        __kfree(skb);
    else
        skb->users = users - 1;
}

Alexey
