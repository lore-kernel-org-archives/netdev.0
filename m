From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] bonding: use l4 hash if available
Date: Tue, 15 Sep 2015 16:20:28 -0700
Message-ID: <1442359228.4116.17.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1442355868.4116.14.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAF2d9jgb_MP==6Go-quk=9s_Nyg8ewgFzfkvUi-y5j_7zBqksw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33845 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751465AbbIOXUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 19:20:30 -0400
Received: by padhy16 with SMTP id hy16so189422900pad.1
        for <netdev@vger.kernel.org>; Tue, 15 Sep 2015 16:20:30 -0700 (PDT)
In-Reply-To: <CAF2d9jgb_MP==6Go-quk=9s_Nyg8ewgFzfkvUi-y5j_7zBqksw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-09-15 at 15:54 -0700, Mahesh Bandewar wrote:

> > +       if (bond->params.xmit_policy == BOND_XMIT_POLICY_ENCAP34 &&
> > +           skb->l4_hash)
> if (ENCAP34 || LAYER34) && l4_hash) may be?

Hmm, traditional BOND_XMIT_POLICY_LAYER34 did not a full flow bisection
(tunnel awareness added in commit
32819dc1834866cb9547cb75f81af9edd58d33cd bonding: modify the old and add
new xmit hash policies)

This could radically change some setups and behavior.

BOND_XMIT_POLICY_ENCAP34 looks a better fit to me.
