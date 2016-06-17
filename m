From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next v6] tcp: Add RFC4898 tcpEStatsPerfDataSegsOut/In
Date: Fri, 17 Jun 2016 14:34:17 -0700
Message-ID: <20160617213417.GA16126@kafai-mba.local>
References: <1457977935-2018863-1-git-send-email-kafai@fb.com>
 <1466137828.7945.211.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>,
	Chris Rapier <rapier@psc.edu>,
	Eric Dumazet <edumazet@google.com>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:47167 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750986AbcFQVef (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 17:34:35 -0400
Content-Disposition: inline
In-Reply-To: <1466137828.7945.211.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 16, 2016 at 09:30:28PM -0700, Eric Dumazet wrote:
> On Mon, 2016-03-14 at 10:52 -0700, Martin KaFai Lau wrote:
> > Per RFC4898, they count segments sent/received
> > containing a positive length data segment (that includes
> > retransmission segments carrying data).  Unlike
> > tcpi_segs_out/in, tcpi_data_segs_out/in excludes segments
> > carrying no data (e.g. pure ack).
> >
> > The patch also updates the segs_in in tcp_fastopen_add_skb()
> > so that segs_in >= data_segs_in property is kept.
> >
> > Together with retransmission data, tcpi_data_segs_out
> > gives a better signal on the rxmit rate.
> >
> > v6: Rebase on the latest net-next
> >
> > v5: Eric pointed out that checking skb->len is still needed in
> > tcp_fastopen_add_skb() because skb can carry a FIN without data.
> > Hence, instead of open coding segs_in and data_segs_in, tcp_segs_in()
> > helper is used.  Comment is added to the fastopen case to explain why
> > segs_in has to be reset and tcp_segs_in() has to be called before
> > __skb_pull().
> >
> > v4: Add comment to the changes in tcp_fastopen_add_skb()
> > and also add remark on this case in the commit message.
> >
> > v3: Add const modifier to the skb parameter in tcp_segs_in()
> >
> > v2: Rework based on recent fix by Eric:
> > commit a9d99ce28ed3 ("tcp: fix tcpi_segs_in after connection establishment")
> >
> > Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> > Cc: Chris Rapier <rapier@psc.edu>
> > Cc: Eric Dumazet <edumazet@google.com>
> > Cc: Marcelo Ricardo Leitner <mleitner@redhat.com>
> > Cc: Neal Cardwell <ncardwell@google.com>
> > Cc: Yuchung Cheng <ycheng@google.com>
> > Acked-by: Eric Dumazet <edumazet@google.com>
> > ---
>
> Hi Martin
>
> Have you sent the iproute2 ss corresponding patch ?
Sorry, I did not.  I will work on it shortly.

Thanks for bringing it up!
