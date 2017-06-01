From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/3] udp: avoid a cache miss on dequeue
Date: Thu, 01 Jun 2017 13:50:48 -0700
Message-ID: <1496350248.27480.19.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1496070490.git.pabeni@redhat.com>
         <b07f7111480bb0ca2d98fe9fef49a593ab1c4787.1496070490.git.pabeni@redhat.com>
         <1496250043.27480.6.camel@edumazet-glaptop3.roam.corp.google.com>
         <1496313592.4872.14.camel@redhat.com>
         <1496332699.27480.14.camel@edumazet-glaptop3.roam.corp.google.com>
         <1496334113.9312.8.camel@redhat.com>
         <CANn89iKznSPH9VogQEPSw4bLL8F_L_qj2ZY2M==VZ-O1u0xqiA@mail.gmail.com>
         <1496349346.2798.1.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33177 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751284AbdFAUuv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 16:50:51 -0400
Received: by mail-pf0-f174.google.com with SMTP id e193so37280730pfh.0
        for <netdev@vger.kernel.org>; Thu, 01 Jun 2017 13:50:50 -0700 (PDT)
In-Reply-To: <1496349346.2798.1.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-06-01 at 22:35 +0200, Paolo Abeni wrote:

> To make the code robust we would have to NULL all the other fields
> (nfct, nf_bridge, destructor, sk) that are currently not cleared in
> skb_release_head_state(), elsewhere if one day, after some change, any
> that fields become non-NULL in this code path we risk a double-free
> after skb_release_head_state(), even if the code looks safe.

Well, one can not predict future bugs, and we should not add code just
trying to prevent future bugs.

> 
> Will that be a little too invasive for this small use-case? Can't we
> prefer a new helper or simply a secpath_reset() plus some appropriate
> comments?

Please reuse existing functions, and amend them if needed.

Fact that we mention secpath_put() or secpath_reset() in an UDP patch
should really tell us something is wrong. This is becoming a maintenance
burden.
