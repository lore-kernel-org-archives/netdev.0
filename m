From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: Align RX buffers
Date: Sun, 30 Apr 2017 22:50:56 -0400 (EDT)
Message-ID: <20170430.225056.522551868142970014.davem@davemloft.net>
References: <20170429001741.14563-1-swood@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@cavium.com, ariel.elior@cavium.com,
        everest-linux-l2@cavium.com, netdev@vger.kernel.org,
        edumazet@google.com, mschmidt@redhat.com,
        linuxppc-dev@lists.ozlabs.org
To: swood@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54650 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S637843AbdEACu7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 22:50:59 -0400
In-Reply-To: <20170429001741.14563-1-swood@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Wood <swood@redhat.com>
Date: Fri, 28 Apr 2017 19:17:41 -0500

> The bnx2x driver is not providing proper alignment on the receive buffers it
> passes to build_skb(), causing skb_shared_info to be misaligned.
> skb_shared_info contains an atomic, and while PPC normally supports
> unaligned accesses, it does not support unaligned atomics.
> 
> Aligning the size of rx buffers will ensure that page_frag_alloc() returns
> aligned addresses.
> 
> This can be reproduced on PPC by setting the network MTU to 1450 (or other
> non-multiple-of-4) and then generating sufficient inbound network traffic
> (one or two large "wget"s usually does it), producing the following oops:
 ...
> Fixes: d46d132cc021 ("bnx2x: use netdev_alloc_frag()")
> Signed-off-by: Scott Wood <swood@redhat.com>

Applied, thanks.
