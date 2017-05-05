From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net] tcp: randomize timestamps on syncookies
Date: Fri, 05 May 2017 12:00:43 -0400 (EDT)
Message-ID: <20170505.120043.1050625612733133272.davem@davemloft.net>
References: <1493949548.7796.32.camel@edumazet-glaptop3.roam.corp.google.com>
        <1493950957.7796.36.camel@edumazet-glaptop3.roam.corp.google.com>
        <1493992614.7796.46.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45296 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752528AbdEEQAs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 12:00:48 -0400
In-Reply-To: <1493992614.7796.46.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 05 May 2017 06:56:54 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Whole point of randomization was to hide server uptime, but an attacker
> can simply start a syn flood and TCP generates 'old style' timestamps,
> directly revealing server jiffies value.
> 
> Also, TSval sent by the server to a particular remote address vary
> depending on syncookies being sent or not, potentially triggering PAWS
> drops for innocent clients.
> 
> Lets implement proper randomization, including for SYNcookies.
> 
> Also we do not need to export sysctl_tcp_timestamps, since it is not
> used from a module.
> 
> In v2, I added Florian feedback and contribution, adding tsoff to
> tcp_get_cookie_sock().
> 
> v3 removed one unused variable in tcp_v4_connect() as Florian spotted.
> 
> Fixes: 95a22caee396c ("tcp: randomize tcp timestamp offsets for each connection")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reviewed-by: Florian Westphal <fw@strlen.de>
> Tested-by: Florian Westphal <fw@strlen.de>

Applied and queued up for -stable, thanks Eric.
