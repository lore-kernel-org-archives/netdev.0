From: Pekka Savola <pekkas@netcore.fi>
Subject: multicast IP datagram forwarding bug and fix (fwd)
Date: Mon, 4 Aug 2003 09:06:04 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0308040905260.11876-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I didn't see followups to this, so I'm re-sending to the list just in case 
it got dropped in the cracks..

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
---------- Forwarded message ----------
Date: Mon, 28 Jul 2003 13:20:31 -0400
From: "Weng, Wending" <WWending@oerlikon.ca>
To: netdev@oss.sgi.com
Subject: multicast IP datagram forwarding bug and fix

> Hi,
> 
>    LINUX doesn't forward multicast IP datagram if it has option(s), there is is a bug in the module ipmr.c, function
> ipmr_forward_finish, below is the current version of this function:
> 
> static inline int ipmr_forward_finish(struct sk_buff *skb)
> {
>         struct dst_entry *dst = skb->dst;
> 
>         if (skb->len <= dst->pmtu)
>                 return dst->output(skb);
>         else
>                 return ip_fragment(skb, dst->output);
> }
> 
> it forgets to recalculate the checksum in case the option is modified.
> 
> The following code works properly:
> 
> static inline int ipmr_forward_finish(struct sk_buff *skb)
> {
>         struct dst_entry *dst = skb->dst;
> 
>         ip_forward_options (skb); /* this line recalculates checksum if needed. */
> 
>         if (skb->len <= dst->pmtu)
>                 return dst->output(skb);
>         else
>                 return ip_fragment(skb, dst->output);
> }
> 
> Wending Weng
