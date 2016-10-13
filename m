From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] net: Require exact match for TCP socket lookups if dif is
 l3mdev
Date: Thu, 13 Oct 2016 15:39:23 -0600
Message-ID: <e9dbd5f6-4a8d-1763-5533-1aa39dd6ff25@cumulusnetworks.com>
References: <1476389690-31211-1-git-send-email-dsa@cumulusnetworks.com>
 <1476394191.5650.29.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33659 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756762AbcJMVji (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 17:39:38 -0400
Received: by mail-pf0-f172.google.com with SMTP id 128so40504124pfz.0
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 14:39:26 -0700 (PDT)
In-Reply-To: <1476394191.5650.29.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/13/16 3:29 PM, Eric Dumazet wrote:
> Since netif_index_is_l3_master() is not cheap, can you reorder the
> test ?
> 
> if (!net->ipv4.sysctl_tcp_l3mdev_accept)
>         return netif_index_is_l3_master(net, dif);

sure. Since this use case is called under rcu_read_lock I can make a netif_index_is_l3_master_rcu which saves a few cycles.
