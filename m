From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: reset ct before calling ndo_start_xmit
Date: Tue, 24 Jan 2017 06:04:27 -0800
Message-ID: <1485266667.16328.290.camel@edumazet-glaptop3.roam.corp.google.com>
References: <e33476125bdaf4619c221aa82c034831bbdce89b.1485250657.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Florian Westphal <fw@strlen.de>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33094 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750708AbdAXOE3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 09:04:29 -0500
Received: by mail-pg0-f68.google.com with SMTP id 194so16794505pgd.0
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 06:04:29 -0800 (PST)
In-Reply-To: <e33476125bdaf4619c221aa82c034831bbdce89b.1485250657.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-01-24 at 10:40 +0100, Paolo Abeni wrote:

> Currently we use the NETIF_F_LLTX feature bit to identify such devices,
> since all the [legacy] phys drivers setting such bit are not prone
> the hangup issue. The plan is adding a specific 'this is a
> virtual device' priv flag and use it instead, in a later net-next
> patch.

This is too ugly in my opinion.

LLTX is LLTX, and has absolutely nothing to do with connection tracking.

We have ndo_features_check, and this can be trivially backported to
stable versions.

No need for yet another flag really.
