From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug in skb_segment: fskb->len != len
Date: Mon, 28 Oct 2013 06:21:11 -0700
Message-ID: <1382966471.13037.18.camel@edumazet-glaptop.roam.corp.google.com>
References: <20131028115552.GC4408@cpaasch-mac>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:42355 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756367Ab3J1NVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 09:21:14 -0400
Received: by mail-pd0-f182.google.com with SMTP id q10so7024498pdj.41
        for <netdev@vger.kernel.org>; Mon, 28 Oct 2013 06:21:12 -0700 (PDT)
In-Reply-To: <20131028115552.GC4408@cpaasch-mac>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-10-28 at 12:55 +0100, Christoph Paasch wrote:
> Hello,
> 
> I have been seeing the below BUG in skb_segment with the latest net-next
> head on my router.
> 
> I am forwarding Multipath TCP-traffic on this router. The MPTCP-sender is simply
> doing an iperf-session. Strangely, I cannot reproduce the bug when sending
> regular TCP-traffic across the router.
> Note: The crash happens on a vanilla net-next kernel. It does not has any
> MPTCP-code in it.
> 
> I bisected it down to 8a29111c7c (net: gro: allow to build full sized skb),
> but I guess 8a29111c7c is just revealing a more fundamental bug in skb_segment.
> 
> Some info I found:
> In skb_segment, when the bug happens, fskb->len is 4284 but the mss and len is 1428.

fskb seems to contain 3 segments -> 3*1428 = 4284, so it looks fine

But what do you mean by 'len is 1428' ?

> Shortly before the bug happens, skb_gro_receive is building a packet where
> lp->len is equal to 4284 inside the frag_list.
> 
> 
> Seems like skb_segment cannot handle those bigger skb's in the frag_list.
> 

Thanks for the report, I'll take a look.

As mentioned earlier, building very large skbs (with a frag_list) for a
router makes little sense, because we need to segment them before NIC
ndo_start_xmit()

But we also need to fix the skb_segment() bug anyway.

Thanks !
