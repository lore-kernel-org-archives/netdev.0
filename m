From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] dctcp: avoid bogus doubling of cwnd after loss
Date: Mon, 31 Oct 2016 15:18:58 -0400 (EDT)
Message-ID: <20161031.151858.1022634913420322302.davem@davemloft.net>
References: <1477672991-19181-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, brakmo@fb.com,
        agshew@gmail.com, glenn.judd@morganstanley.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56338 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S945730AbcJaTTA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 15:19:00 -0400
In-Reply-To: <1477672991-19181-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Fri, 28 Oct 2016 18:43:11 +0200

> If a congestion control module doesn't provide .undo_cwnd function,
> tcp_undo_cwnd_reduction() will set cwnd to
> 
>    tp->snd_cwnd = max(tp->snd_cwnd, tp->snd_ssthresh << 1);
> 
> ... which makes sense for reno (it sets ssthresh to half the current cwnd),
> but it makes no sense for dctcp, which sets ssthresh based on the current
> congestion estimate.
> 
> This can cause severe growth of cwnd (eventually overflowing u32).
> 
> Fix this by saving last cwnd on loss and restore cwnd based on that,
> similar to cubic and other algorithms.
> 
> Fixes: e3118e8359bb7c ("net: tcp: add DCTCP congestion control algorithm")
> Cc: Lawrence Brakmo <brakmo@fb.com>
> Cc: Andrew Shewmaker <agshew@gmail.com>
> Cc: Glenn Judd <glenn.judd@morganstanley.com>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied and queued up for -stable, thanks Florian.
