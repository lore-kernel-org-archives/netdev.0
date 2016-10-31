From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ip6_tunnel: Clear IP6CB in ip6_tnl_xmit() after
 encapsulation
Date: Mon, 31 Oct 2016 14:18:49 -0400 (EDT)
Message-ID: <20161031.141849.2021537115231143799.davem@davemloft.net>
References: <CALx6S36O_MUQw4vWKUoW-ZgCTg9PJrPjNHwuEWTDG9t=BxQv3w@mail.gmail.com>
        <9a1bb72b-246d-021a-236c-f523832964ac@gmx.com>
        <20161028190757.26be756c@halley>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: elicooper@gmx.com, tom@herbertland.com, netdev@vger.kernel.org
To: shmulik.ladkani@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55060 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755682AbcJaSSv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 14:18:51 -0400
In-Reply-To: <20161028190757.26be756c@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Date: Fri, 28 Oct 2016 19:07:57 +0300

> On Fri, 28 Oct 2016 13:13:45 +0800 Eli Cooper <elicooper@gmx.com> wrote:
>> Maybe we
>> should clear IP6CB in ip6tunnel_xmit(), rather than in every tunnel's codes?
> 
> This seems reasonable.
> 
> A potential issue might be whether it needs to be done earlier, although
> I've reviewed current versions of both 'ip6_tnl_xmit' and
> 'udp_tunnel6_xmit_skb' and it looks okay. But please verify.
> 
>> By the way, I don't see any point in setting IPCB(skb)->flags in
>> udp_tunnel6_xmit_skb(). It will not be interpreted as IPCB any further
>> past ip6tunnel_xmit(), even if it were not cleared. Plus, nothing seems
>> to use these flags anyway.
> 
> This seems right.
> 
> It was introduced in 6a93cc9052 "udp-tunnel: Add a few more UDP tunnel APIs".
> 
> If you checkout that tree, you'll notice same treatment to
> IPCB(skb)->opt and IPCB(skb)->flags in l2tp_xmit_skb... maybe it was
> just copied ;-)

I think for now, we should clear IP6CB in ip6tunnel_xmit()
unconditionally, and remove the IPCB() stuff from the UDP tunneling
code.

If we need some kind of preservation of some of the IP6CB(skb)->flag
bits for whatever reason, we can add that later.  Right now that
code was producing essentially garbage.
