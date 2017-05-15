From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/3] udp: use a separate rx queue for packet
 reception
Date: Mon, 15 May 2017 09:10:49 -0700
Message-ID: <1494864649.6465.1.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1494837879.git.pabeni@redhat.com>
         <e97d459f9b0af848acde4a51d1ac434b15e5a6b7.1494837879.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33453 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966234AbdEOQKv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 12:10:51 -0400
Received: by mail-pg0-f66.google.com with SMTP id s62so17519935pgc.0
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 09:10:51 -0700 (PDT)
In-Reply-To: <e97d459f9b0af848acde4a51d1ac434b15e5a6b7.1494837879.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-05-15 at 11:01 +0200, Paolo Abeni wrote:
> under udp flood the sk_receive_queue spinlock is heavily contended.
> This patch try to reduce the contention on such lock adding a
> second receive queue to the udp sockets; recvmsg() looks first
> in such queue and, only if empty, tries to fetch the data from
> sk_receive_queue. The latter is spliced into the newly added
> queue every time the receive path has to acquire the
> sk_receive_queue lock.
> 
> The accounting of forward allocated memory is still protected with
> the sk_receive_queue lock, so udp_rmem_release() needs to acquire
> both locks when the forward deficit is flushed.
> 
> On specific scenarios we can end up acquiring and releasing the
> sk_receive_queue lock multiple times; that will be covered by
> the next patch
> 
> Suggested-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---

Very nice, thanks for working on this Paolo.

Acked-by: Eric Dumazet <edumazet@google.com>
