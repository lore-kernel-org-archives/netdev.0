From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] TCP_NOTSENT_LOWAT behavior
Date: Fri, 17 Feb 2017 07:38:16 -0800
Message-ID: <1487345896.1311.80.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1487312405-18480-1-git-send-email-johunt@akamai.com>
         <1487315225.1311.76.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org, jbaron@akamai.com
To: Josh Hunt <johunt@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34801 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934065AbdBQPiS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 10:38:18 -0500
Received: by mail-pf0-f194.google.com with SMTP id o64so4332460pfb.1
        for <netdev@vger.kernel.org>; Fri, 17 Feb 2017 07:38:18 -0800 (PST)
In-Reply-To: <1487315225.1311.76.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-02-16 at 23:07 -0800, Eric Dumazet wrote:

> This adds a cost to fast path. tcp_sendmsg() is insane.
> 
> We have one skb granularity (64KB) already for SO_SNDBUF, regardless of
> TCP_NOTSENT_LOWAT being used or not.

Note that this granularity is wanted for performance, otherwise our per
task 32KB page (current->task_frag) might be split in very small chunks
over multiple sockets on applications dealing with many TCP sockets.

Having nice initial 64KB TSO packets with 2 or 3 frags allows for better
sack coalescing

Ref :
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=3613b3dbd1ade9a6a626dae1f608c57638eb5e8a

Thanks.
