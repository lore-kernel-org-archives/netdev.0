From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: sctp gso should set feature with NETIF_F_SG
 when calling skb_segment
Date: Wed, 25 Jan 2017 12:29:04 -0500 (EST)
Message-ID: <20170125.122904.176544590271598853.davem@davemloft.net>
References: <7b4d081c051650e706ffda360fdfbd4baaa1a317.1485237916.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55072 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751429AbdAYR3G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 12:29:06 -0500
In-Reply-To: <7b4d081c051650e706ffda360fdfbd4baaa1a317.1485237916.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Tue, 24 Jan 2017 14:05:16 +0800

> Now sctp gso puts segments into skb's frag_list, then processes these
> segments in skb_segment. But skb_segment handles them only when gs is
> enabled, as it's in the same branch with skb's frags.
> 
> Although almost all the NICs support sg other than some old ones, but
> since commit 1e16aa3ddf86 ("net: gso: use feature flag argument in all
> protocol gso handlers"), features &= skb->dev->hw_enc_features, and
> xfrm_output_gso call skb_segment with features = 0, which means sctp
> gso would call skb_segment with sg = 0, and skb_segment would not work
> as expected.
> 
> This patch is to fix it by setting features param with NETIF_F_SG when
> calling skb_segment so that it can go the right branch to process the
> skb's frag_list.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied, thanks.
