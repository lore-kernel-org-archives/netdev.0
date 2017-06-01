From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net-next 2/3] udp: avoid a cache miss on dequeue
Date: Thu, 1 Jun 2017 09:40:55 -0700
Message-ID: <CANn89iKznSPH9VogQEPSw4bLL8F_L_qj2ZY2M==VZ-O1u0xqiA@mail.gmail.com>
References: <cover.1496070490.git.pabeni@redhat.com> <b07f7111480bb0ca2d98fe9fef49a593ab1c4787.1496070490.git.pabeni@redhat.com>
 <1496250043.27480.6.camel@edumazet-glaptop3.roam.corp.google.com>
 <1496313592.4872.14.camel@redhat.com> <1496332699.27480.14.camel@edumazet-glaptop3.roam.corp.google.com>
 <1496334113.9312.8.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f173.google.com ([209.85.161.173]:36723 "EHLO
        mail-yw0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752043AbdFAQk5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 12:40:57 -0400
Received: by mail-yw0-f173.google.com with SMTP id b68so22520756ywe.3
        for <netdev@vger.kernel.org>; Thu, 01 Jun 2017 09:40:56 -0700 (PDT)
In-Reply-To: <1496334113.9312.8.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 1, 2017 at 9:21 AM, Paolo Abeni <pabeni@redhat.com> wrote:

> I'm sorry, I do not follow. I'm concerned about the secpath field (skb-
>>sp), which is the only one that can be not NULL in
> __udp_queue_rcv_skb().
>
> If the secpath is not NULL, calling there secpath_reset() (or the to-
> be-introduced skb_reset_head_state()), we will properly release it and
> we will clear the field, too.
>
> Calling skb_release_head_state() in the same scenario, we release the
> secpath, but we don't clear it. So if the packet is later dropped we
> will get a double free, unless we add and use a specialized a
> free_stateless_skb(), too.

Then simply use secpath_reset() instead of secpath_put() from
skb_release_head_state()

Clearly having these subtle differences bring confusion, for very little gain.

secpath_put() should be removed. Most of its callers simply set
skb->sp back to NULL anyway.
