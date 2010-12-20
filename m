From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-2.6] net_sched: always clone skbs
Date: Tue, 21 Dec 2010 00:20:20 +0100
Message-ID: <20101220232020.GB2052@del.dom.local>
References: <1292855730-19265-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Pawel Staszewski <pstaszewski@itcare.pl>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f45.google.com ([209.85.214.45]:63831 "EHLO
	mail-bw0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751535Ab0LTXU0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 18:20:26 -0500
Received: by bwz16 with SMTP id 16so3920936bwz.4
        for <netdev@vger.kernel.org>; Mon, 20 Dec 2010 15:20:24 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1292855730-19265-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 20, 2010 at 10:35:30PM +0800, Changli Gao wrote:
> Pawel reported a panic related to handling shared skbs in ixgbe
> incorrectly. So we need to revert my previous patch to work around
> this bug. Instead of reverting the patch completely, I just revert
> the essential lines, so we can add the previous optimization
> back more easily in future.
> 
>     commit 3511c9132f8b1e1b5634e41a3331c44b0c13be70
>     Author: Changli Gao <xiaosuo@gmail.com>
>     Date:   Sat Oct 16 13:04:08 2010 +0000
>     
>         net_sched: remove the unused parameter of qdisc_create_dflt()
> 

Isn't there some mistake in the commit number? IMHO this changelog is
mostly wrong. The bug happens outside of ixgbe, probably in
dev_hard_start_xmit() ->  __skb_linearize(), and even if not, it can,
without any driver's fault. The only question is why it didn't triger
with 2.6.36.

Jarek P.
