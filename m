From: "Thomas 'Dent' Mirlacher" <dent@cosy.sbg.ac.at>
Subject: Re: kfree_skb: unnecessary check ?
Date: Wed, 19 Jun 2002 21:51:02 +0200 (MET DST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.05.10206192147180.14054-100000@mausmaki.cosy.sbg.ac.at>
References: <3D10B6FE.1050602@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <3D10B6FE.1050602@trash.net>
List-Id: netdev.vger.kernel.org

patrick,

--snip/snip
> static inline void kfree_skb(struct sk_buff *skb)
> {
-     if (atomic_read(&skb->users) == 1)
+     if (likely(atomic_read(&skb->users) == 1))
>         __kfree(skb);
>     else
>         atomic_dec(&skb->users);
> }

is even faster for the likely case by 1 2 jmps (gcc3.1).
(well, is it the likely case?)

	tm

-- 
in some way i do, and in some way i don't.
