From: "Weng, Wending" <WWending@oerlikon.ca>
Subject: multicast IP datagram forwarding bug and fix
Date: Mon, 28 Jul 2003 13:20:31 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <AE20493C16DE7F46BC29B257C8D708D3157500@mail.oerlikon.ca>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

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
