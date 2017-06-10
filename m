From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv6: Initial skb->dev and skb->protocol in
 ip6_output
Date: Sat, 10 Jun 2017 07:54:21 -0700
Message-ID: <1497106461.736.102.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1497035168-9093-1-git-send-email-chenbofeng.kernel@gmail.com>
         <20170609.150836.1427149901008136163.davem@davemloft.net>
         <3270a030-2608-1629-07d6-7fdeee9e98cc@gmail.com>
         <20170609.153937.1403217696199851743.davem@davemloft.net>
         <3e187bb4-df36-1791-aa92-03a348b68b14@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        lorenzo@google.com, edumazet@google.com, fengc@google.com
To: Chenbo Feng <chenbofeng.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:32984 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751958AbdFJOyY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 10:54:24 -0400
Received: by mail-pf0-f193.google.com with SMTP id w12so1632789pfk.0
        for <netdev@vger.kernel.org>; Sat, 10 Jun 2017 07:54:24 -0700 (PDT)
In-Reply-To: <3e187bb4-df36-1791-aa92-03a348b68b14@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-06-09 at 16:12 -0700, Chenbo Feng wrote:
> 
> On 06/09/2017 12:39 PM, David Miller wrote:
> > From: Chenbo Feng <chenbofeng.kernel@gmail.com>
> > Date: Fri, 9 Jun 2017 12:13:57 -0700
> >
> >>
> >> On 06/09/2017 12:08 PM, David Miller wrote:
> >>> From: Chenbo Feng <chenbofeng.kernel@gmail.com>
> >>> Date: Fri,  9 Jun 2017 12:06:07 -0700
> >>>
> >>>> From: Chenbo Feng <fengc@google.com>
> >>>>
> >>>> Move the initialization of skb->dev and skb->protocol from
> >>>> ip6_finish_output2 to ip6_output. This can make the skb->dev and
> >>>> skb->protocol information avalaible to the CGROUP eBPF filter.
> >>>>
> >>>> Signed-off-by: Chenbo Feng <fengc@google.com>
> >>>> Acked-by: Eric Dumazet <edumazet@google.com>
> >>> Applied, thanks.
> >>>
> >>> This makes ipv6 consistent with ipv4.
> >>>
> >>> I am surprised this wasn't noticed, for example, in netfilter.
> >>> .
> >>>
> >> Hi David,
> >>
> >> This patch is still under working since it may have problem with
> >> ip_fragment() call, did you applied it already? Should I send a revert
> >> patch to you then?
> > A revert is necessary or a relative fixup.
> >
> > Thank you.
> >
> Hi David,
> 
> The revert is uploaded here: http://patchwork.ozlabs.org/patch/774136/
> 
> Thanks and sorry for the trouble caused
> 
> Chenbo Feng

No worries !

It seems the revert is not needed, after further analysis.

One of the point I raised was this no longer needed chunk, that can be
added as a separate patch :

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 02cd44f0953900108701895108b2fdaa9f9980e5..0d6f3b6345de26c329ae1d6f25dde652a5452d4b 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -869,7 +869,6 @@ int ip6_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
 	if (skb->sk && dst_allfrag(skb_dst(skb)))
 		sk_nocaps_add(skb->sk, NETIF_F_GSO_MASK);
 
-	skb->dev = skb_dst(skb)->dev;
 	icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 	err = -EMSGSIZE;
 
