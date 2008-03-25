From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: Re: [PATCH 2/3] [LLC]: bogus llc packet length
Date: Tue, 25 Mar 2008 14:16:40 +0900
Message-ID: <b25c3fa70803242216w6267905aq26e126891a9e1aba@mail.gmail.com>
References: <47e7678b.1aba720a.6925.fffff466@mx.google.com>
	 <20080324164310.GD32612@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joonwpark81@gmail.com,
	"Arnaldo Carvalho de Melo" <acme@redhat.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.185]:49277 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754255AbYCYFQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 01:16:41 -0400
Received: by rv-out-0910.google.com with SMTP id k20so1654280rvb.1
        for <netdev@vger.kernel.org>; Mon, 24 Mar 2008 22:16:40 -0700 (PDT)
In-Reply-To: <20080324164310.GD32612@ghostprotocols.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/3/25, Arnaldo Carvalho de Melo <acme@redhat.com>:
> Em Mon, Mar 24, 2008 at 05:34:16PM +0900, joonwpark81@gmail.com escreveu:
> > From: Joonwoo Park <joonwpark81@gmail.com>
> >
> > discard llc packet which has bogus packet length.
> >
> > Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
> > ---
> > diff --git a/net/llc/llc_input.c b/net/llc/llc_input.c
> > index c40c9b2..a2bbc7c 100644
> > --- a/net/llc/llc_input.c
> > +++ b/net/llc/llc_input.c
> > @@ -117,8 +117,12 @@ static inline int llc_fixup_skb(struct sk_buff *skb)
> >       skb_pull(skb, llc_len);
> >       if (skb->protocol == htons(ETH_P_802_2)) {
> >               __be16 pdulen = eth_hdr(skb)->h_proto;
> > -             u16 data_size = ntohs(pdulen) - llc_len;
> > +             s32 data_size = ntohs(pdulen) - llc_len;
> >
> > +             if (data_size < 0
> > +                 || ((skb_tail_pointer(skb) - (u8 *)pdu) - llc_len)
> > +                     < data_size)
> > +                     return 0;
>
> Rewrite this as:
>
>                if (data_size < 0 ||
>                    ((skb_tail_pointer(skb) -
>                      (u8 *)pdu) - llc_len) < data_size)

Thanks Arnaldo.
Dave, I'll update this with the others.

>
> And stick my:
>
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
>
> :-)

Thanks,
Joonwoo
