From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sock: avoid dirtying sk_stamp, if possible
Date: Thu, 30 Mar 2017 20:29:24 -0700 (PDT)
Message-ID: <20170330.202924.1023519735753552178.davem@davemloft.net>
References: <f29d595f4a72d77730447be2a7c5f243fad47751.1490875313.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38302 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753900AbdCaD32 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 23:29:28 -0400
In-Reply-To: <f29d595f4a72d77730447be2a7c5f243fad47751.1490875313.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Thu, 30 Mar 2017 14:03:06 +0200

> sock_recv_ts_and_drops() unconditionally set sk->sk_stamp for
> every packet, even if the SOCK_TIMESTAMP flag is not set in the
> related socket.
> If selinux is enabled, this cause a cache miss for every packet
> since sk->sk_stamp and sk->sk_security share the same cacheline.
> With this change sk_stamp is set only if the SOCK_TIMESTAMP
> flag is set, and is cleared for the first packet, so that the user
> perceived behavior is unchanged.
> 
> This gives up to 5% speed-up under udp-flood with small packets.
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied, thanks.
