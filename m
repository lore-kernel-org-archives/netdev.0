From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] net: add recursion limit to GRO
Date: Thu, 20 Oct 2016 14:32:52 -0400 (EDT)
Message-ID: <20161020.143252.1084197903325642557.davem@davemloft.net>
References: <7429d1a2eaceec5e4563be8c67e86e1a515f21b5.1476971359.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
        tom@herbertland.com, jbenc@redhat.com, hannes@stressinduktion.org
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44346 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753343AbcJTScy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 14:32:54 -0400
In-Reply-To: <7429d1a2eaceec5e4563be8c67e86e1a515f21b5.1476971359.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Thu, 20 Oct 2016 15:58:02 +0200

> Currently, GRO can do unlimited recursion through the gro_receive
> handlers.  This was fixed for tunneling protocols by limiting tunnel GRO
> to one level with encap_mark, but both VLAN and TEB still have this
> problem.  Thus, the kernel is vulnerable to a stack overflow, if we
> receive a packet composed entirely of VLAN headers.
> 
> This patch adds a recursion counter to the GRO layer to prevent stack
> overflow.  When a gro_receive function hits the recursion limit, GRO is
> aborted for this skb and it is processed normally.  This recursion
> counter is put in the GRO CB, but could be turned into a percpu counter
> if we run out of space in the CB.
> 
> Thanks to Vladimír Bene¨ <vbenes@redhat.com> for the initial bug report.
> 
> Fixes: CVE-2016-7039
> Fixes: 9b174d88c257 ("net: Add Transparent Ethernet Bridging GRO support.")
> Fixes: 66e5133f19e9 ("vlan: Add GRO support for non hardware accelerated vlan")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> Reviewed-by: Jiri Benc <jbenc@redhat.com>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable, thanks!
