From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 3/3] udp: try to avoid 2 cache miss on
 dequeue
Date: Tue, 06 Jun 2017 13:58:35 -0700
Message-ID: <1496782715.736.14.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1496756090.git.pabeni@redhat.com>
         <cdbe7b4e6758719d3e02938f05c8575d009e2822.1496756090.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34178 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751247AbdFFU6h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 16:58:37 -0400
Received: by mail-pf0-f193.google.com with SMTP id u1so503860pfg.1
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 13:58:37 -0700 (PDT)
In-Reply-To: <cdbe7b4e6758719d3e02938f05c8575d009e2822.1496756090.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-06-06 at 16:23 +0200, Paolo Abeni wrote:
> when udp_recvmsg() is executed, on x86_64 and other archs, most skb
> fields are on cold cachelines.
> If the skb are linear and the kernel don't need to compute the udp
> csum, only a handful of skb fields are required by udp_recvmsg().
> Since we already use skb->dev_scratch to cache hot data, and
> there are 32 bits unused on 64 bit archs, use such field to cache
> as much data as we can, and try to prefetch on dequeue the relevant
> fields that are left out.

Acked-by: Eric Dumazet <edumazet@google.com>
