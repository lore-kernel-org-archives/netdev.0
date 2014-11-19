From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH net-next v2] ipvlan: Initial check-in of the IPVLAN driver.
Date: Tue, 18 Nov 2014 21:27:48 -0800
Message-ID: <CAF2d9jjrN4cDmtN_yKTe0BS+cAqE=hqgsT_6mOEBuMTTPOaPRg@mail.gmail.com>
References: <1416205634-26611-1-git-send-email-maheshb@google.com> <20141118.155437.1582768084232091503.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	=?ISO-8859-2?Q?Maciej_=AFenczykowski?= <maze@google.com>,
	Laurent Chavey <chavey@google.com>,
	Tim Hockin <thockin@google.com>, brandon.philips@coreos.com,
	xemul@parallels.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f181.google.com ([209.85.220.181]:39591 "EHLO
	mail-vc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754664AbaKSF2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 00:28:09 -0500
Received: by mail-vc0-f181.google.com with SMTP id le20so6769696vcb.12
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 21:28:08 -0800 (PST)
In-Reply-To: <20141118.155437.1582768084232091503.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 18, 2014 at 12:54 PM, David Miller <davem@davemloft.net> wrote:
>
> From: Mahesh Bandewar <maheshb@google.com>
> Date: Sun, 16 Nov 2014 22:27:14 -0800
>
> > +/* Define IPVL_DEBUG and set the appropriate dbg_level for debugging. */
> > +#ifdef       IPVL_DEBUG
> > +/*
> > + * 1 : non-datapath debugging
> > + * 2 : Custom
> > + * 3 : function enters and exists.
> > + * 4 : printk in data path (be careful!)
> > + */
> > +#define IPVL_DBG_LEVEL 1
> > +#define ipvlan_dbg(level, msg...)    do { \
> > +                                             if (level <= IPVL_DBG_LEVEL) \
> > +                                             printk(KERN_DEBUG msg); \
> > +                                     } while (0)
> > +#else
> > +#define ipvlan_dbg(level, msg...) do { ; } while (0)
> > +#endif
>
> The day of having code use custom local debug logging facilities is long
> gone, please use a standard mechanism for this rather than home cooked
> reimplementations.
>
Do you mean pr_err() / pr_warn() / pr_debug() etc.? or something else?

> > +/* ---- Prototype declarations ---- */
> > +/* ---- ipvlan_main.c ---- */
>
> Everone knows these are prototype declarations by virtue of them being
> functions declarations in a header file.
>
> Anyone who wants to know where these are defined can run grep.
>
> So these comments are superfluous, please remove them across this
> entire submission.
>
> > +     const struct in_addr *ip4_addr = iaddr;
> > +     return jhash_1word(ip4_addr->s_addr, ipvlan_jhash_secret)
> > +            & IPVLAN_HASH_MASK;
>
> When an expression spans multiple lines, lines end rather than begin
> with an operator.
>
> > +             if (is_v6 && addr->atype == IPVL_IPV6 &&
> > +                     ipv6_addr_equal(&addr->ip6addr, iaddr))
>
> For multi-line if() statements, the second line and subsequent lines
> must begine exactly at the first column after the openning parenthesis
> of the first line.
>
> If you are purely using TAB characters to indent, you are likely doing
> it wrong.
> > +             if ((is_v6 && addr->atype == IPVL_IPV6 &&
> > +                  ipv6_addr_equal(&addr->ip6addr, iaddr))
> > +                || (!is_v6 && addr->atype == IPVL_IPV4 &&
> > +                   addr->ip4addr.s_addr == ((struct in_addr *)iaddr)->s_addr)
>
> Lines end, not begin, with operators.
>
> > --- /dev/null
> > +++ b/drivers/net/ipvlan/ipvlan_sysfs.c
>
> Please do not add sysfs configuration knobs, netlink is sufficient.

Having it does neither add complexity nor too much code, wo why not?
May be I'm missing something! But I was think that this might provide
foundation for adding other things like config locking from master's
namespace etc. (discussed in the thread) in the future.

Thanks,
--mahesh..
