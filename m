From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] udp: do rmem bulk free even if the rx sk
 queue is empty
Date: Wed, 20 Sep 2017 14:29:14 -0700 (PDT)
Message-ID: <20170920.142914.865968677643614093.davem@davemloft.net>
References: <f82856528a033394c407539d1ff4b92e243bad36.1505815819.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38548 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751586AbdITV3P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 17:29:15 -0400
In-Reply-To: <f82856528a033394c407539d1ff4b92e243bad36.1505815819.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Tue, 19 Sep 2017 12:11:43 +0200

> The commit 6b229cf77d68 ("udp: add batching to udp_rmem_release()")
> reduced greatly the cacheline contention between the BH and the US
> reader batching the rmem updates in most scenarios.
> 
> Such optimization is explicitly avoided if the US reader is faster
> then BH processing.
> 
> My fault, I initially suggested this kind of behavior due to concerns
> of possible regressions with small sk_rcvbuf values. Tests showed
> such concerns are misplaced, so this commit relaxes the condition
> for rmem bulk updates, obtaining small but measurable performance
> gain in the scenario described above.
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied, thanks Paolo.
