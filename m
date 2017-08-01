From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] udp6: fix jumbogram reception
Date: Mon, 31 Jul 2017 22:01:54 -0700 (PDT)
Message-ID: <20170731.220154.2302589425459107320.davem@davemloft.net>
References: <70ca36ffa44fb8d6c369a1ab2866220916e2904a.1501512228.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lorenzo@google.com,
        dsa@cumulusnetworks.com, david.lebrun@uclouvain.be,
        hannes@stressinduktion.org
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51448 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751038AbdHAFB4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 01:01:56 -0400
In-Reply-To: <70ca36ffa44fb8d6c369a1ab2866220916e2904a.1501512228.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Mon, 31 Jul 2017 16:52:36 +0200

> Since commit 67a51780aebb ("ipv6: udp: leverage scratch area
> helpers") udp6_recvmsg() read the skb len from the scratch area,
> to avoid a cache miss.
> But the UDP6 rx path support RFC 2675 UDPv6 jumbograms, and their
> length exceeds the 16 bits available in the scratch area. As a side
> effect the length returned by recvmsg() is:
> <ingress datagram len> % (1<<16)
> 
> This commit addresses the issue allocating one more bit in the
> IP6CB flags field and setting it for incoming jumbograms.
> Such field is still in the first cacheline, so at recvmsg()
> time we can check it and fallback to access skb->len if
> required, without a measurable overhead.
> 
> Fixes: 67a51780aebb ("ipv6: udp: leverage scratch area helpers")
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied, thanks Paolo.
