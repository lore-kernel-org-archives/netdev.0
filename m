From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/5] net: add support for noref skb->sk
Date: Wed, 20 Sep 2017 10:41:35 -0700
Message-ID: <1505929295.29839.103.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1505926196.git.pabeni@redhat.com>
         <39b55ec9584df7dfd6eb498a3d354cd2e08e3eaa.1505926196.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:37041 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751024AbdITRlh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 13:41:37 -0400
Received: by mail-pf0-f193.google.com with SMTP id e69so1450918pfg.4
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 10:41:37 -0700 (PDT)
In-Reply-To: <39b55ec9584df7dfd6eb498a3d354cd2e08e3eaa.1505926196.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-09-20 at 18:54 +0200, Paolo Abeni wrote:
> Noref sk do not carry a socket refcount, are valid
> only inside the current RCU section and must be
> explicitly cleared before exiting such section.
> 
> They will be used in a later patch to allow early demux
> without sock refcounting.




> +/* dummy destructor used by noref sockets */
> +void sock_dummyfree(struct sk_buff *skb)
> +{

BUG();

> +}
> +EXPORT_SYMBOL(sock_dummyfree);
> +


I do not see how you ensure we do not leave RCU section with an skb
destructor pointing to this sock_dummyfree()

This patch series looks quite dangerous to me.

Do we really have real applications using connected UDP sockets and
wanting very high pps throughput ?

I am pretty sure the bottleneck is the sender part.
