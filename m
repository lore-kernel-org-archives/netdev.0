From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp/dccp: block BH for SYN processing
Date: Wed, 01 Mar 2017 15:04:43 -0800 (PST)
Message-ID: <20170301.150443.1062358693675562555.davem@davemloft.net>
References: <CAAeHK+xe+5Kr4-jd7zhBgX=3VrsTB4p8Lz0F5bTtW21vVT=Hag@mail.gmail.com>
        <CANn89iKK9_Gao1fZ9mJEujBFMvZuOu534PE-VnSKUBkpYzr7qw@mail.gmail.com>
        <1488386389.9415.298.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, andreyknvl@google.com, netdev@vger.kernel.org,
        dvyukov@google.com, soheil@google.com, ast@kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54086 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753469AbdCAX3d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 18:29:33 -0500
In-Reply-To: <1488386389.9415.298.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 01 Mar 2017 08:39:49 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> SYN processing really was meant to be handled from BH.
> 
> When I got rid of BH blocking while processing socket backlog
> in commit 5413d1babe8f ("net: do not block BH while processing socket
> backlog"), I forgot that a malicious user could transition to TCP_LISTEN
> from a state that allowed (SYN) packets to be parked in the socket
> backlog while socket is owned by the thread doing the listen() call.
> 
> Sure enough syzkaller found this and reported the bug ;)
 ...
> Fixes: 5413d1babe8f ("net: do not block BH while processing socket backlog")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>

Applied and queued up for -stable, thanks.
