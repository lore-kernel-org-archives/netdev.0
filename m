From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 2/3] udp: avoid a cache miss on dequeue
Date: Tue, 06 Jun 2017 13:53:33 -0700
Message-ID: <1496782413.736.12.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1496756090.git.pabeni@redhat.com>
         <25a17e660ebc766ef6af918d7607dde4706f0c23.1496756090.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:35769 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751452AbdFFUxg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 16:53:36 -0400
Received: by mail-pf0-f174.google.com with SMTP id l89so27567045pfi.2
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 13:53:36 -0700 (PDT)
In-Reply-To: <25a17e660ebc766ef6af918d7607dde4706f0c23.1496756090.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-06-06 at 16:23 +0200, Paolo Abeni wrote:
> Since UDP no more uses sk->destructor, we can clear completely
> the skb head state before enqueuing. Amend and use
> skb_release_head_state() for that.
> 
> All head states share a single cacheline, which is not
> normally used/accesses on dequeue. We can avoid entirely accessing
> such cacheline implementing and using in the UDP code a specialized
> skb free helper which ignores the skb head state.
> 
> This saves a cacheline miss at skb deallocation time.

Acked-by: Eric Dumazet <edumazet@google.com>
