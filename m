From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] loopback: clear pfmemalloc on outgoing skb's
Date: Wed, 01 Feb 2017 18:46:28 -0800
Message-ID: <1486003588.13103.12.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1485983078-2372-1-git-send-email-jbacik@fb.com>
         <1485992285.6360.168.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com,
        "David S . Miller" <davem@davemloft.net>
To: Josef Bacik <jbacik@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35897 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750726AbdBBCqa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 21:46:30 -0500
Received: by mail-pg0-f65.google.com with SMTP id 75so370856pgf.3
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2017 18:46:30 -0800 (PST)
In-Reply-To: <1485992285.6360.168.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-02-01 at 15:38 -0800, Eric Dumazet wrote:

> I am not sure this is a proper fix.
> 
> Presumably if the socket was able to store packets in its write queue,
> fact that it sends it to loopback or an Ethernet link should not matter.
> 
> Only in RX path the pfmemalloc thing is really important.
> 
> So I would rather not set skb->pfmemalloc for skbs allocated for the
> write queue, and more exactly the fast clone.

Also note that any looped packet would have the problem : veth, macvlan,
ipvlan, ...
