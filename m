From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH net-next 2/2] bonding: use l4 hash if available
Date: Tue, 15 Sep 2015 17:04:04 -0700
Message-ID: <CAF2d9jg7rkfvH1J8Ttf5dokAo=jnZi6ujkdM9m9BGWJeX62yNQ@mail.gmail.com>
References: <1442355868.4116.14.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAF2d9jgb_MP==6Go-quk=9s_Nyg8ewgFzfkvUi-y5j_7zBqksw@mail.gmail.com> <1442359228.4116.17.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f176.google.com ([209.85.160.176]:34133 "EHLO
	mail-yk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751681AbbIPAE0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 20:04:26 -0400
Received: by ykdg206 with SMTP id g206so202989006ykd.1
        for <netdev@vger.kernel.org>; Tue, 15 Sep 2015 17:04:24 -0700 (PDT)
In-Reply-To: <1442359228.4116.17.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 15, 2015 at 4:20 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2015-09-15 at 15:54 -0700, Mahesh Bandewar wrote:
>
>> > +       if (bond->params.xmit_policy == BOND_XMIT_POLICY_ENCAP34 &&
>> > +           skb->l4_hash)
>> if (ENCAP34 || LAYER34) && l4_hash) may be?
>
> Hmm, traditional BOND_XMIT_POLICY_LAYER34 did not a full flow bisection
> (tunnel awareness added in commit
> 32819dc1834866cb9547cb75f81af9edd58d33cd bonding: modify the old and add
> new xmit hash policies)
>
> This could radically change some setups and behavior.
>
> BOND_XMIT_POLICY_ENCAP34 looks a better fit to me.
>
Agreed, this will change flow distribution for LAYER34 policy but then
loose out on calculating hash per packet which I think is unnecessary.

This elimination of hash calculation is a good step but I'm feeling
that it's somehow tied to ENCAP policy which is actually orthogonal
and should be applied to LAYER34 also. However if that change in the
behavior for LAYER34 is considered too drastic then I'm perfectly fine
tying it to ENCAP34 policy.

>
