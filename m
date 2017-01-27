From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: don't annotate mark on control socket from
 tcp_v6_send_response()
Date: Fri, 27 Jan 2017 10:34:20 -0500 (EST)
Message-ID: <20170127.103420.1380044626135112317.davem@davemloft.net>
References: <1485467781-1842-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
        eric.dumazet@gmail.com
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36506 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754971AbdA0PfJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 10:35:09 -0500
In-Reply-To: <1485467781-1842-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Thu, 26 Jan 2017 22:56:21 +0100

> Unlike ipv4, this control socket is shared by all cpus so we cannot use
> it as scratchpad area to annotate the mark that we pass to ip6_xmit().
> 
> Add a new parameter to ip6_xmit() to indicate the mark. The SCTP socket
> family caches the flowi6 structure in the sctp_transport structure, so
> we cannot use to carry the mark unless we later on reset it back, which
> I discarded since it looks ugly to me.
> 
> Fixes: bf99b4ded5f8 ("tcp: fix mark propagation with fwmark_reflect enabled")
> Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Looks good to me and matches Eric's suggestion.

Applied, thanks Pablo.
