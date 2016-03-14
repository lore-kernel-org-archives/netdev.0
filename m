From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v6] tcp: Add RFC4898
 tcpEStatsPerfDataSegsOut/In
Date: Mon, 14 Mar 2016 15:01:22 -0400 (EDT)
Message-ID: <20160314.150122.1145761338928283612.davem@davemloft.net>
References: <1457977935-2018863-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com, rapier@psc.edu,
	edumazet@google.com, mleitner@redhat.com, ncardwell@google.com,
	ycheng@google.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48789 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752479AbcCNTBZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 15:01:25 -0400
In-Reply-To: <1457977935-2018863-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Mon, 14 Mar 2016 10:52:15 -0700

> Per RFC4898, they count segments sent/received
> containing a positive length data segment (that includes
> retransmission segments carrying data).  Unlike
> tcpi_segs_out/in, tcpi_data_segs_out/in excludes segments
> carrying no data (e.g. pure ack).
> 
> The patch also updates the segs_in in tcp_fastopen_add_skb()
> so that segs_in >= data_segs_in property is kept.
> 
> Together with retransmission data, tcpi_data_segs_out
> gives a better signal on the rxmit rate.
> 
> v6: Rebase on the latest net-next
> 
> v5: Eric pointed out that checking skb->len is still needed in
> tcp_fastopen_add_skb() because skb can carry a FIN without data.
> Hence, instead of open coding segs_in and data_segs_in, tcp_segs_in()
> helper is used.  Comment is added to the fastopen case to explain why
> segs_in has to be reset and tcp_segs_in() has to be called before
> __skb_pull().
> 
> v4: Add comment to the changes in tcp_fastopen_add_skb()
> and also add remark on this case in the commit message.
> 
> v3: Add const modifier to the skb parameter in tcp_segs_in()
> 
> v2: Rework based on recent fix by Eric:
> commit a9d99ce28ed3 ("tcp: fix tcpi_segs_in after connection establishment")
> 
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> Cc: Chris Rapier <rapier@psc.edu>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Marcelo Ricardo Leitner <mleitner@redhat.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
