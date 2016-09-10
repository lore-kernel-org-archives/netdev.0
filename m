From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: identify chunks that need to be fragmented
 at IP level
Date: Fri, 09 Sep 2016 19:18:52 -0700 (PDT)
Message-ID: <20160909.191852.1305298210334990557.davem@davemloft.net>
References: <d3a35eae75b431862cf96b55dd3a3614a11df8a3.1473328451.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, vyasevich@gmail.com,
        daniel@iogearbox.net
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35554 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752015AbcIJCS4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 22:18:56 -0400
In-Reply-To: <d3a35eae75b431862cf96b55dd3a3614a11df8a3.1473328451.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Thu,  8 Sep 2016 17:54:11 +0800

> From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> 
> Previously, without GSO, it was easy to identify it: if the chunk didn't
> fit and there was no data chunk in the packet yet, we could fragment at
> IP level. So if there was an auth chunk and we were bundling a big data
> chunk, it would fragment regardless of the size of the auth chunk. This
> also works for the context of PMTU reductions.
> 
> But with GSO, we cannot distinguish such PMTU events anymore, as the
> packet is allowed to exceed PMTU.
> 
> So we need another check: to ensure that the chunk that we are adding,
> actually fits the current PMTU. If it doesn't, trigger a flush and let
> it be fragmented at IP level in the next round.
> 
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Applied.
