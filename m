From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [v8 PATCH 2/3] NETFILTER module xt_hmark, new target for HASH based fwmark
Date: Wed, 8 Feb 2012 15:07:13 +0100
Message-ID: <201202081507.15489.hans.schillstrom@ericsson.com>
References: <1327675303-9059-1-git-send-email-hans.schillstrom@ericsson.com> <1327675303-9059-3-git-send-email-hans.schillstrom@ericsson.com> <20120208002743.GA29189@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "kaber@trash.net" <kaber@trash.net>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hans@schillstrom.com" <hans@schillstrom.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120208002743.GA29189@1984>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 08 February 2012 01:27:43 Pablo Neira Ayuso wrote:
> On Fri, Jan 27, 2012 at 03:41:42PM +0100, Hans Schillstrom wrote:
> > diff --git a/include/linux/netfilter/xt_hmark.h b/include/linux/netfilter/xt_hmark.h
> > new file mode 100644
> > index 0000000..f2ac47b
> > --- /dev/null
> > +++ b/include/linux/netfilter/xt_hmark.h
> > @@ -0,0 +1,71 @@
> > +#ifndef XT_HMARK_H_
> > +#define XT_HMARK_H_
> > +
> > +#include <linux/types.h>
> > +
> > +/*
> > + * Flags must not start at 0, since it's used as none.
> 
> Then, define XT_HMARK_NONE = 0.
> 
> Please, once this is done, remove this comment.

OK

> 
> > + */
> > +enum {
> > +     XT_HMARK_SADR_AND = 1,  /* SNAT & DNAT are used by the kernel module */
>                                               ^^^^^
> I don't understand why that comment is there.
> 
> > +     XT_HMARK_DADR_AND,
> > +     XT_HMARK_SPI_AND,
> > +     XT_HMARK_SPI_OR,
> > +     XT_HMARK_SPORT_AND,
> > +     XT_HMARK_DPORT_AND,
> > +     XT_HMARK_SPORT_OR,
> > +     XT_HMARK_DPORT_OR,
> > +     XT_HMARK_PROTO_AND,
> > +     XT_HMARK_RND,
> > +     XT_HMARK_MODULUS,
> > +     XT_HMARK_OFFSET,
> > +     XT_HMARK_USE_SNAT,
> > +     XT_HMARK_USE_DNAT,
> > +     XT_HMARK_METHOD_L3,
> > +     XT_HMARK_METHOD_L3_4,
> > +     XT_F_HMARK_USE_SNAT = 1 << XT_HMARK_USE_SNAT,
> 
> You can probably do something like this to beautify this defintion:
> 
> XT_F_HMARK_WHATEVER     = (1 << XT_HMARK_BLAH),
> XT_F_HMARK_BLOB         = (1 << XT_HMARK_BLAHBLAH),
> 
> With some tabs, and so on.

Sure, except for the ()

> 
> > +     XT_F_HMARK_USE_DNAT = 1 << XT_HMARK_USE_DNAT,
> > +     XT_F_HMARK_SADR_AND = 1 << XT_HMARK_SADR_AND,
> > +     XT_F_HMARK_DADR_AND = 1 << XT_HMARK_DADR_AND,
> > +     XT_F_HMARK_SPI_AND = 1 << XT_HMARK_SPI_AND,
> > +     XT_F_HMARK_SPI_OR = 1 << XT_HMARK_SPI_OR,
> > +     XT_F_HMARK_SPORT_AND = 1 << XT_HMARK_SPORT_AND,
> > +     XT_F_HMARK_DPORT_AND = 1 << XT_HMARK_DPORT_AND,
> > +     XT_F_HMARK_SPORT_OR = 1 << XT_HMARK_SPORT_OR,
> > +     XT_F_HMARK_DPORT_OR = 1 << XT_HMARK_DPORT_OR,
> > +     XT_F_HMARK_PROTO_AND = 1 << XT_HMARK_PROTO_AND,
> > +     XT_F_HMARK_RND = 1 << XT_HMARK_RND,
> > +     XT_F_HMARK_MODULUS = 1 << XT_HMARK_MODULUS,
> > +     XT_F_HMARK_OFFSET = 1 << XT_HMARK_OFFSET,
> > +     XT_F_HMARK_METHOD_L3 = 1 << XT_HMARK_METHOD_L3,
> > +     XT_F_HMARK_METHOD_L3_4 = 1 << XT_HMARK_METHOD_L3_4,
> > +};
> > +
> > +#define XT_F_HMARK_L4_OPTS  (XT_F_HMARK_SPI_AND | XT_F_HMARK_SPI_OR\
> > +                          | XT_F_HMARK_SPORT_AND | XT_F_HMARK_SPORT_OR\
> > +                          | XT_F_HMARK_DPORT_AND | XT_F_HMARK_DPORT_OR\
> > +                          | XT_F_HMARK_PROTO_AND)
> 
> I find nobody using this definition in the kernel. Please, move it
> where it belong.

OK I'll move it to userspace
> 
> > +
> > +union hports {
> 
> this is exposed to user-space. Please, use xt_hmark_ports or something
> similar to make sure we don't have any clash in the name-space.
> 
> Better. Define this structure inside xt_hmark_info since it only seems
> to be useful there, I'd say.
> 
OK it goes to libxt_HMARK

> > +     struct {
> > +             __u16   src;
> > +             __u16   dst;
> > +     } p16;
> > +     __u32   v32;
> > +};
> > +
[snip]


> > +++ b/net/netfilter/xt_hmark.c
> > @@ -0,0 +1,334 @@
> > +/*
> > + * xt_hmark - Netfilter module to set mark as hash value
> > + *
> > + * (C) 2011 Hans Schillstrom <hans.schillstrom@ericsson.com>
> > + *
> > + *Description:
> > + *   This module calculates a hash value that can be modified by modulus
> > + *   and an offset, i.e. it is possible to produce a skb->mark within a range.
> > + *   The hash value is based on a direction independent five tuple:
> > + *   src & dst addr src & dst ports and protocol.
> 
> This description above I think it's sufficient.
> 
> I think you can remove this header below. The documentation will be
> available through the manpage.
> 

OK
[snip]

> > +
> > +     /* Try to get transport header */
> 
> I like comments, but this is completely unnecessary, it's clear what
> the function below does. Please, use comments only when necessary, ie.
> in case that there's something which is not evident to the person that
> is reading the code.
> 
OK don't blame me, I will remove the comments. :-)

> > +     nexthdr = ipv6_find_hdr(skb, &nhoffs, -1, &fragoff, &flag);
> > +     if (nexthdr < 0)
> > +             return XT_CONTINUE;
> > +     /* don't check for icmp on fragments */
> > +     if ((flag & IP6T_FH_F_FRAG) || (nexthdr != IPPROTO_ICMPV6))
> > +             goto noicmp;
> > +     /* ICMP: if an error then move ptr to inner header */
> > +     if (get_inner6_hdr(skb, &nhoffs)) {
> > +             /* Get IPv6 header ptr just to get the saddr & daddr later */
> > +             ip6 = skb_header_pointer(skb, nhoffs, sizeof(_ip6), &_ip6);
> > +             if (!ip6)
> > +                     return XT_CONTINUE;
> > +             /* Treat AH as ESP */
> > +             flag = IP6T_FH_F_AUTH;
> > +             nexthdr = ipv6_find_hdr(skb, &nhoffs, -1, &fragoff, &flag);
> > +             if (nexthdr < 0)
> > +                     return XT_CONTINUE;
> > +     }
> > +noicmp:
> > +     /* Mask of the address and xor it into a u32 */
> > +     addr1 = (__force u32)
> > +             (ip6->saddr.s6_addr32[0] & info->smask.in6.s6_addr32[0]) ^
> > +             (ip6->saddr.s6_addr32[1] & info->smask.in6.s6_addr32[1]) ^
> > +             (ip6->saddr.s6_addr32[2] & info->smask.in6.s6_addr32[2]) ^
> > +             (ip6->saddr.s6_addr32[3] & info->smask.in6.s6_addr32[3]);
> > +     addr2 = (__force u32)
> > +             (ip6->daddr.s6_addr32[0] & info->dmask.in6.s6_addr32[0]) ^
> > +             (ip6->daddr.s6_addr32[1] & info->dmask.in6.s6_addr32[1]) ^
> > +             (ip6->daddr.s6_addr32[2] & info->dmask.in6.s6_addr32[2]) ^
> > +             (ip6->daddr.s6_addr32[3] & info->dmask.in6.s6_addr32[3]);
> > +
> > +     /* user space tool ensures that prmask is zero when method is L3*/
> 
> You can to double check this in checkentry.

OK I was not aware of checkentry in the kernel-code.

> 
> > +     if ((info->flags & XT_F_HMARK_METHOD_L3) ||
> > +         (nexthdr == IPPROTO_ICMPV6))
> > +             goto no6ports;
> > +
[snip]

> > +static unsigned int
> > +hmark_v4(struct sk_buff *skb, const struct xt_action_param *par)
> > +{
> > +     struct xt_hmark_info *info = (struct xt_hmark_info *)par->targinfo;
> > +     int nhoff, poff, frag = 0;
> > +     struct iphdr *ip, _ip;
> > +     u8 ip_proto;
> > +     u32 addr1, addr2, hash;
> > +     u16 snatport = 0, dnatport = 0;
> > +     union hports uports;
> > +#if defined(CONFIG_NF_NAT)
> 
> remove this #if defined, not required at all.

Yes it is, if you don't want to wase cpu cycles 
more correct is this:
#if defined(CONFIG_NF_NAT) || defined(CONFIG_NF_NAT_MODULE)

> 
> > +     enum ip_conntrack_info ctinfo;
> > +     struct nf_conn *ct = ct = nf_ct_get(skb, &ctinfo);
> 
>                        ^^^^^^^^
> please, this is redundant, no need for it. Remove it.

Ooops,

> 
> > +#endif
> > +
> > +     nhoff = skb_network_offset(skb);
> > +     uports.v32 = 0;
> > +
> > +     ip = (struct iphdr *) (skb->data + nhoff);
> > +     if (ip->protocol == IPPROTO_ICMP) {
> > +             /* calc hash on inner header if an icmp error */
> > +             nhoff = get_inner_hdr(skb, ip->ihl * 4, nhoff);
> > +             ip = skb_header_pointer(skb, nhoff, sizeof(_ip), &_ip);
> > +             if (!ip)
> > +                     return XT_CONTINUE;
> > +     }
> > +
> > +     ip_proto = ip->protocol;
> > +     if (ip->frag_off & htons(IP_MF | IP_OFFSET))
> > +             frag = 1;
> > +
> > +     addr1 = (__force u32) ip->saddr & info->smask.ip;
> > +     addr2 = (__force u32) ip->daddr & info->dmask.ip;
> > +
> > +#if defined(CONFIG_NF_NAT)
> > +     if (ct && test_bit(IP_CT_IS_REPLY, &ct->status)) {
> > +             struct nf_conntrack_tuple *otuple;
> > +
> > +             otuple = &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple;
> > +             /*
> > +              * On the "return flow", to get the original address
> > +              */
> > +             if ((ct->status & IPS_DST_NAT) &&
> > +                     (info->flags & XT_HMARK_USE_DNAT)) {
> > +                     addr1 = (__force u32) otuple->dst.u3.in.s_addr;
> > +                     dnatport = otuple->dst.u.udp.port;
> > +             }
> > +             if ((ct->status & IPS_SRC_NAT) &&
> > +                     (info->flags & XT_HMARK_USE_SNAT)) {
> > +                     addr2 = (__force u32) otuple->src.u3.in.s_addr;
> > +                     snatport = otuple->src.u.udp.port;
> > +             }
> 
> You can make this much more simple.
> 
> Allow the user to tell your HMARK target to use the conntrack
> information instead.

--hmark--use-conntrack, I think  --hmark-use-ct-orig is more clear
If I understand you right you mean a change like this:

+             if ((ct->status & IPS_DST_NAT) &&
+                     (info->flags & XT_HMARK_USE_CT_ORIG_ADDR)) {
...
+             if ((ct->status & IPS_SRC_NAT) &&
+                     (info->flags & XT_HMARK_USE_CT_ORIG_ADDR)) {

> My opinion is that the user must have total control on the target
> behaviour through the configuration options. 
> The number of internal by-default decisions have to be kept up to the minimum, otherwise
> the behaviour of the target may seem obscure.
> 

I think --hmark-use-ct-orig is more intuitive what is does compared to 
  --hmark-ct-orig-src and --hmark-ct-orig-dst
(i.e. you don't have to think about direction.)

> > +     }
> > +#endif
> > +     /* user space tool ensures that prmask is zero when method is L3*/
> 
> No, you have to double check this in checkentry() in kernel-space to
> make sure that user-space.

I was nat aware of that option, but now I am :-)

> 
> I think we need another round for this.

Yea

-- 
Thanks
Hans 
