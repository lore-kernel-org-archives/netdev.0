From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 3/3] net: for rate-limited ICMP replies save
 one atomic operation
Date: Mon, 09 Jan 2017 09:44:23 -0800
Message-ID: <1483983863.5846.5.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170109150246.30215.63371.stgit@firesoul>
         <20170109150414.30215.63724.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33411 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1164009AbdAIRoY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 12:44:24 -0500
Received: by mail-pg0-f66.google.com with SMTP id 194so7759404pgd.0
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 09:44:24 -0800 (PST)
In-Reply-To: <20170109150414.30215.63724.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-01-09 at 16:04 +0100, Jesper Dangaard Brouer wrote:
> It is possible to avoid the atomic operation in icmp{v6,}_xmit_lock,
> by checking the sysctl_icmp_msgs_per_sec ratelimit before these calls,
> as pointed out by Eric Dumazet, but the BH disabled state must be correct.
> 
> The icmp_global_allow() call states it must be called with BH
> disabled.  This protection was given by the calls icmp_xmit_lock and
> icmpv6_xmit_lock.  Thus, split out local_bh_disable/enable from these
> functions and maintain it explicitly at callers.
> 
> Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
