From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH RFC 14/14] net: introduce and use
 KERNEL_MAX_HEADER_PARSE_ADDRLEN
Date: Tue, 3 Mar 2015 18:11:14 +0100
Message-ID: <20150303171114.GF9762@breakpoint.cc>
References: <1425318028-26531-1-git-send-email-fw@strlen.de>
 <1425318028-26531-15-git-send-email-fw@strlen.de>
 <CA+FuTSexA71zArCtidoxYGt0rOn9whaeRnYh7AbgbmOYGDqFTw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	Network Development <netdev@vger.kernel.org>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:57676 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756704AbbCCRLQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 12:11:16 -0500
Content-Disposition: inline
In-Reply-To: <CA+FuTSexA71zArCtidoxYGt0rOn9whaeRnYh7AbgbmOYGDqFTw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Willem de Bruijn <willemb@google.com> wrote:
> > index 6fb6bdf..97eb50c 100644
> > --- a/net/mac802154/iface.c
> > +++ b/net/mac802154/iface.c
> > @@ -433,6 +433,7 @@ mac802154_header_parse(const struct sk_buff *skb, unsigned char *haddr)
> >                 return 0;
> >         }
> >
> > +       dev_validate_header_parse_addrlen(sizeof(*addr));
> >         *addr = hdr.source;
> >         return sizeof(*addr);
> >  }
> > diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> > index 9db8369..1a4dcbb 100644
> > --- a/net/packet/af_packet.c
> > +++ b/net/packet/af_packet.c
> > @@ -1816,7 +1816,8 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
> >                 skb = nskb;
> >         }
> >
> > -       sock_skb_cb_check_size(sizeof(*PACKET_SKB_CB(skb)) + MAX_ADDR_LEN - 8);
> > +       sock_skb_cb_check_size(sizeof(*PACKET_SKB_CB(skb)) +
> > +                              KERNEL_MAX_HEADER_PARSE_ADDRLEN);
> 
> KERNEL_MAX_HEADER_PARSE_ADDRLEN - 8, as the first 8
> bytes are still written into the space allocated in packet_skb_cb?

Good catch, thanks!

I'll make this a FIELD_SIZEOF construct using sll_addr to make
it a bit more obvious where that 8 is coming from.
