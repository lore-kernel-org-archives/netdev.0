From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] udp: use sk_protocol instead of pcflag to
 detect udplite sockets
Date: Sat, 01 Apr 2017 20:12:02 -0700 (PDT)
Message-ID: <20170401.201202.1578661173027016048.davem@davemloft.net>
References: <fc91ec83ecf454fad74c326380203a34434cb1ec.1490953526.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60194 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750814AbdDBDME (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Apr 2017 23:12:04 -0400
In-Reply-To: <fc91ec83ecf454fad74c326380203a34434cb1ec.1490953526.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Fri, 31 Mar 2017 11:47:39 +0200

> In the udp_sock struct, the 'forward_deficit' and 'pcflag' fields
> share the same cacheline. While the first is dirtied by
> udp_recvmsg, the latter is read, possibly several times, by the
> bottom half processing to discriminate between udp and udplite
> sockets.
> 
> With this patch, sk->sk_protocol is used to check is the socket is
> really an udplite one, avoiding some cache misses per
> packet and improving the performance under udp_flood with
> small packet up to 10%.
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied, thanks.
