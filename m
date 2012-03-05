From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [v9 PATCH 2/3] NETFILTER module xt_hmark, new target for HASH
 based fwmark
Date: Mon, 5 Mar 2012 22:37:38 +0100
Message-ID: <20120305213738.GA30032@1984>
References: <1329387672-23683-1-git-send-email-hans.schillstrom@ericsson.com>
 <201203051109.48817.hans.schillstrom@ericsson.com>
 <20120305182248.GA29022@1984>
 <201203052133.54604.hans@schillstrom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hans Schillstrom <hans@schillstrom.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201203052133.54604.hans@schillstrom.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 05, 2012 at 09:33:54PM +0100, Hans Schillstrom wrote:
> Hello,
> On Monday, March 05, 2012 19:22:48 Pablo Neira Ayuso wrote:
> > Let me trim off parts that have been already discussed.
> > 
> > On Mon, Mar 05, 2012 at 11:09:46AM +0100, Hans Schillstrom wrote:
> > [...]
> > > ...
> > > > > +
> > > > > +/*
> > > > > + * ICMP, get header offset if icmp error
> > > > > + */
> > > > > +static int get_inner_hdr(struct sk_buff *skb, int iphsz, int nhoff)
> > > > > +{
> > > > > +     const struct icmphdr *icmph;
> > > > > +     struct icmphdr _ih;
> > > > > +
> > > > > +     /* Not enough header? */
> > > > > +     icmph = skb_header_pointer(skb, nhoff + iphsz, sizeof(_ih), &_ih);
> > > > > +     if (icmph == NULL)
> > > > > +             return nhoff;
> > > > 
> > > > I think this has to return -1 in this case.
> > > 
> > > No, it must return the unchanged value of nhoffs.
> > > Unless I change the usge of it as described later.
> > 
> > I see, you're defaulting on the original header if you cannot get the
> > ICMP header (eg. fragment case).
> > 
> > > > > +
> > > > > +     if (icmph->type > NR_ICMP_TYPES)
> > > > > +             return nhoff;
> > > > 
> > > > Same thing.
> > > 
> > > Same comment.
> > 
> > So if you get an unsupportted ICMP message, you rely on the original
> > IP header.
> >
> 
> Yes, thats right.
> 
> >
> [snip]
> > 
> > I think you can do like in other parts of netfilter:
> > 
> > union hmark_ports _uports = { ... };
> > union hmark_ports *uports;
> > 
> > uports = skb_header_pointer(skb, nhoffs + poff, sizeof(_uports), &_uports);
> > if (uports == NULL)
> >         return XT_CONTINUE;
> > 
> > Then use uports->v32 in the rest of the code.
> 
> If I do so, the original packet might be altered which is very bad.
> i.e. if skb_header_pointer() return skb->data + offset; then I will write
> right into the skb :-(

I see, then use skb_copy_bits(skb, offset, buffer, len) instead of
skb_header_pointer.

Thanks Hans. 
