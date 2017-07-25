From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] udp: preserve head state for IP_CMSG_PASSSEC
Date: Tue, 25 Jul 2017 10:01:37 -0700 (PDT)
Message-ID: <20170725.100137.1154747980323058090.davem@davemloft.net>
References: <0bd907843b74bc2112ad960f7d11e75ca095eee3.1500998196.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, paul@paul-moore.com
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57296 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750974AbdGYRBl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 13:01:41 -0400
In-Reply-To: <0bd907843b74bc2112ad960f7d11e75ca095eee3.1500998196.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Tue, 25 Jul 2017 17:57:47 +0200

> Paul Moore reported a SELinux/IP_PASSSEC regression
> caused by missing skb->sp at recvmsg() time. We need to
> preserve the skb head state to process the IP_CMSG_PASSSEC
> cmsg.
> 
> With this commit we avoid releasing the skb head state in the
> BH even if a secpath is attached to the current skb, and stores
> the skb status (with/without head states) in the scratch area,
> so that we can access it at skb deallocation time, without
> incurring in cache-miss penalties.
> 
> This also avoids misusing the skb CB for ipv6 packets,
> as introduced by the commit 0ddf3fb2c43d ("udp: preserve
> skb->dst if required for IP options processing").
> 
> Clean a bit the scratch area helpers implementation, to
> reduce the code differences between 32 and 64 bits build.
> 
> Reported-by: Paul Moore <paul@paul-moore.com>
> Fixes: 0a463c78d25b ("udp: avoid a cache miss on dequeue")
> Fixes: 0ddf3fb2c43d ("udp: preserve skb->dst if required for IP options processing")
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> Tested-by: Paul Moore <paul@paul-moore.com>

Applied, thanks for tracking this down and fixing it.
