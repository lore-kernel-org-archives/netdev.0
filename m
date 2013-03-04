From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Multicast/Broadcast enhancement: SKB read-only with
 copy-on-write
Date: Mon, 04 Mar 2013 08:28:06 -0800
Message-ID: <1362414486.15793.104.camel@edumazet-glaptop>
References: <CAJ4BwwGs2FebA0jgedDxxmQEXSV=g2B07KBgu4C+0nigLbyvnA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yannick Koehler <yannick@koehler.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:49745 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932104Ab3CDQ2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 11:28:12 -0500
Received: by mail-da0-f46.google.com with SMTP id z8so2632258dad.19
        for <netdev@vger.kernel.org>; Mon, 04 Mar 2013 08:28:12 -0800 (PST)
In-Reply-To: <CAJ4BwwGs2FebA0jgedDxxmQEXSV=g2B07KBgu4C+0nigLbyvnA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-03-04 at 10:29 -0500, Yannick Koehler wrote:
> Hi,
> 
>   Recently I was working into the kernel area where the code handle
> broadcast/multicast in bridge logical interface for example.  It seems
> today inevitable that when we flood, the bridge code has to duplicate
> the full SKB, metadata as well as data, in order to transmit to each
> link under it.  I was wondering if there was way for the SKB system to
> support copy-on-write, such that, from a starting point, the SKB would
> be "frozen" into a read-only mode and then if someone wants to modify
> the SKB metadata/data it is done in a way to preserve the original SKB
> memory, as to ensure that after the SKB has been transmitted over that
> particular link, it can also be used without a full memory copy to be
> sent to subsequent link, simultaneously on multi-core/mutli-interface
> system.
> 
>   I am wondering at what level such work would be consider, is it
> relatively easy, does Linux have anything like that, is it major work,
> since pretty much everyone expect SKB data to be writable (like
> skb_may_pull could be used to obtain a specific client SKB version
> area).  It would probably require a new field in the SKB to indicate
> that this is a read-only/copy-on-write version of a specific "original
> SKB".
> 
>   Anyway, just wanted some thoughts/opinions on the topic regarding
> the scale of such a change.
> 

Current skb handling already provides this "read-only" and
"copy-on-write" management.

We only have to use the correct API where it matters, like
skb_share_check()

For an example, take a look at commit de063b7040dcd9
(bonding: remove packet cloning in recv_probe())

ARP packets for example could be handled in a read-only way.

(You dont really explain what particular problem you have,
ARP is only a guess...)
