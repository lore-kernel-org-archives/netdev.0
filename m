From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v3] ucc_geth: Lockless xmit
Date: Fri, 21 Sep 2012 14:51:29 +0200
Message-ID: <20120921125129.GA21792@electric-eye.fr.zoreil.com>
References: <1348129021-28333-1-git-send-email-Joakim.Tjernlund@transmode.se> <1348218675-3804-1-git-send-email-Joakim.Tjernlund@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:58192 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755097Ab2IUNJu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 09:09:50 -0400
Content-Disposition: inline
In-Reply-To: <1348218675-3804-1-git-send-email-Joakim.Tjernlund@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joakim Tjernlund <Joakim.Tjernlund@transmode.se> :
> Currently ucc_geth_start_xmit wraps IRQ off for the
> whole body just to be safe. By rearranging the code a bit
> one can avoid the lock completely.

Afaics you went a bit too lockless with the queueing disable / enable
logic. The hard_start_xmit handler is run in a locally softirq disabled
section but it will happily race with the napi handler on a different
CPU. Grep netif_tx_lock in tg3.c for it.

The Tx skb free logic probably requires some smp memory barriers as
well since the current skb is used by the ucc_geth driver to sync the
Tx xmit with the napi completion handler.

-- 
Ueimor
