From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v6] tcp: Add RFC4898 tcpEStatsPerfDataSegsOut/In
Date: Thu, 16 Jun 2016 21:30:28 -0700
Message-ID: <1466137828.7945.211.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1457977935-2018863-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Kernel Team <kernel-team@fb.com>,
	Chris Rapier <rapier@psc.edu>,
	Eric Dumazet <edumazet@google.com>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35593 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753425AbcFQEac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 00:30:32 -0400
Received: by mail-pa0-f44.google.com with SMTP id hl6so24508332pac.2
        for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 21:30:32 -0700 (PDT)
In-Reply-To: <1457977935-2018863-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-03-14 at 10:52 -0700, Martin KaFai Lau wrote:
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
> ---

Hi Martin

Have you sent the iproute2 ss corresponding patch ?

Thanks !
