From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [RFC PATCH v2 net-next 2/7] tcp: Merge
 tx_flags/tskey/txstamp_ack in tcp_collapse_retrans
Date: Tue, 19 Apr 2016 10:28:37 -0700
Message-ID: <20160419172837.GA37697@kafai-mba.local>
References: <1461019569-3037369-1-git-send-email-kafai@fb.com>
 <1461019569-3037369-3-git-send-email-kafai@fb.com>
 <CACSApvY5ZdyUO1i2O0KPGJM5meWHFv3hdi9Ew89CH--jFV4yOw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Soheil Hassas Yeganeh <soheil.kdev@gmail.com>,
	Willem de Bruijn <willemb@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Kernel Team <kernel-team@fb.com>
To: Soheil Hassas Yeganeh <soheil@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:57611 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752487AbcDSR2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 13:28:48 -0400
Content-Disposition: inline
In-Reply-To: <CACSApvY5ZdyUO1i2O0KPGJM5meWHFv3hdi9Ew89CH--jFV4yOw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 19, 2016 at 01:32:14AM -0400, Soheil Hassas Yeganeh wrote:
> > +               TCP_SKB_CB(skb)->txstamp_ack =
> > +                       !!(shinfo->tx_flags & SKBTX_ACK_TSTAMP);
>
> Maybe we can skip a conditional jump here (because of !!), by simply
> using the cached bit in next_skb:
> TCP_SKB_CB(skb)->txstamp_ack = TCP_SKB_CB(next_skb)->txstamp_ack;
Recall the tx_flags are merged/combined (and so should be the txstamp_ack).
Would there be a case that TCP_SKB_CB(skb)->txstamp_ack is 1 and
TCP_SKB_CB(next_skb)->txstamp_ack is 0?

I can change it like the following which may help in showing the intention:
if (TCP_SKB_CB(next_skb)->txstamp_ack)
	TCP_SKB_CB(skb)->txstamp_ack = 1;

A bit off topic, I feel like the SKBTX_ACK_TSTAMP and txstamp_ack are sort
of redundant but I have not look into the details yet, so not completely
sure.  It wwould be a separate cleanup patch if it is the case.
