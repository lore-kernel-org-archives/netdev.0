From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] dccp: fix use-after-free in
 dccp_feat_activate_values
Date: Tue, 07 Mar 2017 14:16:03 -0800 (PST)
Message-ID: <20170307.141603.1834989423312592126.davem@davemloft.net>
References: <1488556814.9415.334.camel@edumazet-glaptop3.roam.corp.google.com>
        <CACT4Y+Zg9PptopGHPBYmf_2hfHg3kTrTkyhQuT9C7Krf4nX6AA@mail.gmail.com>
        <1488739936.9415.368.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, edumazet@google.com, gerrit@erg.abdn.ac.uk,
        netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38156 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756228AbdCGWlH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 17:41:07 -0500
In-Reply-To: <1488739936.9415.368.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 05 Mar 2017 10:52:16 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Dmitry reported crashes in DCCP stack [1]
> 
> Problem here is that when I got rid of listener spinlock, I missed the
> fact that DCCP stores a complex state in struct dccp_request_sock,
> while TCP does not.
> 
> Since multiple cpus could access it at the same time, we need to add
> protection.
 ...
> Fixes: 079096f103fa ("tcp/dccp: install syn_recv requests into ehash table")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Tested-by: Dmitry Vyukov <dvyukov@google.com>

Applied and queued up for -stable.
