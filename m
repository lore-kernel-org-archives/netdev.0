From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: fix harmonize_features() vs NETIF_F_HIGHDMA
Date: Wed, 18 Jan 2017 15:25:14 -0500 (EST)
Message-ID: <20170118.152514.1412023737192147746.davem@davemloft.net>
References: <CAOrHB_A-oJid6RTeQB_xy0GDKsJjvEDwdTepMXN336qSi5h8AA@mail.gmail.com>
        <1484769077.13165.111.camel@edumazet-glaptop3.roam.corp.google.com>
        <1484770337.13165.120.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@ovn.org, ashiduka@jp.fujitsu.com, fugang.duan@nxp.com,
        netdev@vger.kernel.org, pshelar@nicira.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40566 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753290AbdARUfs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 15:35:48 -0500
In-Reply-To: <1484770337.13165.120.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 18 Jan 2017 12:12:17 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Ashizuka reported a highmem oddity and sent a patch for freescale
> fec driver.
> 
> But the problem root cause is that core networking stack
> must ensure no skb with highmem fragment is ever sent through
> a device that does not assert NETIF_F_HIGHDMA in its features.
> 
> We need to call illegal_highdma() from harmonize_features()
> regardless of CSUM checks.
> 
> Fixes: ec5f06156423 ("net: Kill link between CSUM and SG features.")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Pravin Shelar <pshelar@ovn.org>
> Reported-by: "Ashizuka, Yuusuke" <ashiduka@jp.fujitsu.com>

Applied, thanks Eric.

I guess few devices support SG and lack highmem support.
