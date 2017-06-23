From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] udp: fix poll()
Date: Fri, 23 Jun 2017 11:18:58 -0400 (EDT)
Message-ID: <20170623.111858.1724599210974760106.davem@davemloft.net>
References: <00735477ae8ffcc075e382ab45f6568ab158a0bf.1498220186.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
        edumazet@google.com, mpe@ellerman.id.au,
        linuxppc-dev@lists.ozlabs.org
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60398 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752878AbdFWPTA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 11:19:00 -0400
In-Reply-To: <00735477ae8ffcc075e382ab45f6568ab158a0bf.1498220186.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Fri, 23 Jun 2017 14:19:51 +0200

> Michael reported an UDP breakage caused by the commit b65ac44674dd
> ("udp: try to avoid 2 cache miss on dequeue").
> The function __first_packet_length() can update the checksum bits
> of the pending skb, making the scratched area out-of-sync, and
> setting skb->csum, if the skb was previously in need of checksum
> validation.
> 
> On later recvmsg() for such skb, checksum validation will be
> invoked again - due to the wrong udp_skb_csum_unnecessary()
> value - and will fail, causing the valid skb to be dropped.
> 
> This change addresses the issue refreshing the scratch area in
> __first_packet_length() after the possible checksum update.
> 
> Fixes: b65ac44674dd ("udp: try to avoid 2 cache miss on dequeue")
> Reported-by: Michael Ellerman <mpe@ellerman.id.au>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Thanks for fixing this so quickly, applied.
