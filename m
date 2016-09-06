From: Florian Westphal <fw@strlen.de>
Subject: Re: PROBLEM: TPROXY and DNAT broken (bisected to 079096f103fa)
Date: Wed, 7 Sep 2016 00:57:07 +0200
Message-ID: <20160906225707.GD20188@breakpoint.cc>
References: <BL2PR07MB2306908C76E928619A24B52E9E0F0@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20160729132154.GB13634@breakpoint.cc>
 <BL2PR07MB2306B2B920C441DF5406B1439E050@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20160802221121.GB31209@breakpoint.cc>
 <BL2PR07MB23061A24DD64E80532DBD9799E060@BL2PR07MB2306.namprd07.prod.outlook.com>
 <BL2PR07MB2306C9A7EB393F441D56E7D69E1E0@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20160812190319.GB25519@breakpoint.cc>
 <BL2PR07MB23066ABAF5223701D17CFFF29E120@BL2PR07MB2306.namprd07.prod.outlook.com>
 <BL2PR07MB23065A58E771485F53D553E99EF90@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Florian Westphal <fw@strlen.de>,
        netfilter-devel@vger.kernel.org
To: Brandon Cazander <brandon.cazander@multapplied.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:36204 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932753AbcIFW5L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 18:57:11 -0400
Content-Disposition: inline
In-Reply-To: <BL2PR07MB23065A58E771485F53D553E99EF90@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brandon Cazander <brandon.cazander@multapplied.net> wrote:

[ cc netfilter-devel ]

> Sorry to resurrect this so much later—I just got back from holidays and this was still on my desk.
> 
> Will anyone have another chance to look at this? It appears that the DIVERT rule is not working in our case, and I wonder if it is possible to fix the TPROXY target as well as the socket target fix that Florian provided.

Are there reproducer instructions available for this?

I don't see how TPROXY can be 'fixed' because when skb (tcp syn) is in
mangle PREROUTING nat transformation(s) have not been set up (yet).

So ip header addresses are all we have.

Only the ack (that finishes 3whs) or retransmitted syns will
have the post-nat address info available.

Ack should work fine with (changed) -m socket since the
socket should already be in the main ehash table.

Syn should also work just fine because Erics changes
should not affect initial listener lookup done by TPROXY.

> It appears as though nobody else has encountered this regression, so I can appreciate that it comes up pretty low on the priority list. If it is not realistic that this will be looked at further, then we will have to look at replacing TPROXY.

If you already need NAT anyway you can also use -j REDIRECT (or exclude
tproxied packets from nat).
