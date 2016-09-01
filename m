From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] softirq: let ksoftirqd do its job
Date: Thu, 01 Sep 2016 05:51:14 -0700
Message-ID: <1472734274.5019.5.camel@edumazet-glaptop3.roam.corp.google.com>
References: <4f1c4b38528762619fff1fa963de8971006c1234.1472460085.git.pabeni@redhat.com>
         <20160831100854.23dad2d8@redhat.com>
         <1472650472.14381.317.camel@edumazet-glaptop3.roam.corp.google.com>
         <1472650688.32433.115.camel@redhat.com>
         <1472652643.14381.320.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160831164216.2901190c@redhat.com>
         <1472661956.14381.335.camel@edumazet-glaptop3.roam.corp.google.com>
         <1472665349.14381.356.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160831214043.2f44cf08@redhat.com>
         <1472676150.14381.363.camel@edumazet-glaptop3.roam.corp.google.com>
         <251f077b-3d46-415d-c5f3-c3dea73a3c88@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <jbrouer@redhat.com>,
        Peter Zijlstra <peterz@infradead.org>,
        David Miller <davem@davemloft.net>,
        Rik van Riel <riel@redhat.com>,
        Paolo Abeni <pabeni@redhat.com>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>, Jonathan Corbet <corbet@lwn.net>
To: Hannes Frederic Sowa <hannes@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35834 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933706AbcIAMvS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 08:51:18 -0400
In-Reply-To: <251f077b-3d46-415d-c5f3-c3dea73a3c88@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-09-01 at 14:05 +0200, Hannes Frederic Sowa wrote:

> Would it make sense to include used socket backlog in udp socket lookup
> compute_score calculation? Just want to throw out the idea, I actually
> could imagine to also cause bad side effects.

Hopefully we can get rid of the backlog for UDP, by no longer having to
lock the socket in RX path, and perform memory charging in a better way.

The backlog for TCP is problematic for high speed flows, and for UDP it
is problematic in flood situations as a single recvmsg() might have to
process thousands of skbs before returning to user space.

What you suggest is going to be difficult :

1) Packets of a 5-tuple (eg QUIC flow) wont all land to the same silo,
and will cause reorders or application issues.

2) SO_ATTACH_REUSEPORT_CBPF wont have access to the socket(s) backlog to
perform the choice.

Thanks.
