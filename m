From: Artem Savkov <asavkov@redhat.com>
Subject: Re: [PATCH net v2] udp: preserve skb->dst if required for IP options
 processing
Date: Fri, 21 Jul 2017 12:53:46 +0200
Message-ID: <20170721105346.tsspktxszzt4tgvs@shodan.usersys.redhat.com>
References: <8261bc94db747d35e48c4201b1f8bd52042ec345.1500363698.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45278 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750737AbdGUKxs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Jul 2017 06:53:48 -0400
Content-Disposition: inline
In-Reply-To: <8261bc94db747d35e48c4201b1f8bd52042ec345.1500363698.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 18, 2017 at 11:57:55AM +0200, Paolo Abeni wrote:
> Eric noticed that in udp_recvmsg() we still need to access
> skb->dst while processing the IP options.
> Since commit 0a463c78d25b ("udp: avoid a cache miss on dequeue")
> skb->dst is no more available at recvmsg() time and bad things
> will happen if we enter the relevant code path.
> 
> This commit address the issue, avoid clearing skb->dst if
> any IP options are present into the relevant skb.
> Since the IP CB is contained in the first skb cacheline, we can
> test it to decide to leverage the consume_stateless_skb()
> optimization, without measurable additional cost in the faster
> path.

This doesn't seem to be enough for XFRM case. CMSG gets eaten up in
selinux-testsuite[1]/inet_socket test in ipsec configuration.

[1] https://github.com/SELinuxProject/selinux-testsuite.git

-- 
Regards,
  Artem
