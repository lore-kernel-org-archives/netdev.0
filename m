From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: reset ct before calling ndo_start_xmit
Date: Tue, 24 Jan 2017 07:42:43 -0800
Message-ID: <1485272563.16328.299.camel@edumazet-glaptop3.roam.corp.google.com>
References: <e33476125bdaf4619c221aa82c034831bbdce89b.1485250657.git.pabeni@redhat.com>
         <1485266667.16328.290.camel@edumazet-glaptop3.roam.corp.google.com>
         <1485270249.2409.10.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Florian Westphal <fw@strlen.de>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35361 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751294AbdAXPmu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 10:42:50 -0500
Received: by mail-pg0-f67.google.com with SMTP id 204so16956372pge.2
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 07:42:50 -0800 (PST)
In-Reply-To: <1485270249.2409.10.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-01-24 at 16:04 +0100, Paolo Abeni wrote:

> Double checking to see if I understood the above correctly: do you
> suggest to call nf_reset() from the affected drivers's
> ndo_features_check(), eventually adding such ndo if needed ?
> 
> I think calling nf_reset() in the common code should be better: the
> conntrack entry is hot in the cache and we may want to clear it early
> for as many devices as possible.

This would add a conditional test, which will be not correctly predicted
by CPU in tunnel or bonding/team very common cases.

While doing it in an affected driver would not penalize fast path.

A little bit harder sure, but performance matters ;)
