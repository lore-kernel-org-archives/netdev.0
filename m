From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RESEND 3/5] [NET]: Protocol Independant Policy Routing Rules Framework
Date: Mon, 31 Jul 2006 17:24:01 +0200
Message-ID: <20060731152401.GI14627@postel.suug.ch>
References: <20060726221100.325687073@postel.suug.ch> <20060726221849.807482409@postel.suug.ch> <Pine.LNX.4.64.0607270158001.4779@d.namei> <20060726.230230.111423566.davem@davemloft.net> <20060727223931.GZ14627@postel.suug.ch> <44CE17B6.2070108@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jmorris@namei.org,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:62930 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932431AbWGaPXm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2006 11:23:42 -0400
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
Content-Disposition: inline
In-Reply-To: <44CE17B6.2070108@tcs.hut.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Ville Nuorvala <vnuorval@tcs.hut.fi> 2006-07-31 17:46
> > Derived from net/ipv6/fib_rules.c
> 
> do you mean net/ipv4/fib_rules.c or net/ipv6/fib6_rules.c? :-)

Hehe, I meant net/ipv4/fib_rules.c :-)

> > +struct fib_rule_hdr
> > +{
> > +	__u8		family;
> > +	__u8		dst_len;
> > +	__u8		src_len;
> > +	__u8		tos;
> > +
> > +	__u8		table;
> > +	__u8		res1;	/* reserved */
> > +	__u8		res2;	/* reserved */
> > +	__u8		action;
> > +
> > +	__u32		flags;
> > +};
> 
> I'm wondering if this is guaranteed to be equvalent to struct rtmsg?
> 
> struct rtmsg
> {
> 	unsigned char		rtm_family;
> 	unsigned char		rtm_dst_len;
> 	unsigned char		rtm_src_len;
> 	unsigned char		rtm_tos;
> 
> 	unsigned char		rtm_table;	/* Routing table id */
> 	unsigned char		rtm_protocol;	/* Routing protocol; see below	*/
> 	unsigned char		rtm_scope;	/* See below */	
> 	unsigned char		rtm_type;	/* See below	*/
> 
> 	unsigned		rtm_flags;
> };
> 
> Won't we otherwise be breaking the existing userland interface?

It is equivalent but you're right, it would break userland
interfaces otherwise. I've defined this new header to add
implicit names and stop the confusion with unused fields.

> > +enum
> > +{
> > +	FRA_UNSPEC,
> > +	FRA_DST,	/* destination address */
> > +	FRA_SRC,	/* source address */
> > +	FRA_IFNAME,	/* interface name */
> > +	FRA_UNUSED1,
> > +	FRA_UNUSED2,
> > +	FRA_PRIORITY,	/* priority/preference */
> > +	FRA_UNUSED3,
> > +	FRA_UNUSED4,
> > +	FRA_UNUSED5,
> > +	FRA_FWMARK,	/* netfilter mark (IPv4) */
> > +	FRA_FLOW,	/* flow/class id */
> > +	__FRA_MAX
> > +};
> > +
> > +#define FRA_MAX (__FRA_MAX - 1)
> > +
> > +enum
> > +{
> > +	FR_ACT_UNSPEC,
> > +	FR_ACT_TO_TBL,		/* Pass to fixed table */
> > +	FR_ACT_RES1,
> > +	FR_ACT_RES2,
> > +	FR_ACT_RES3,
> > +	FR_ACT_RES4,
> > +	FR_ACT_BLACKHOLE,	/* Drop without notification */
> > +	FR_ACT_UNREACHABLE,	/* Drop with ENETUNREACH */
> > +	FR_ACT_PROHIBIT,	/* Drop with EACCES */
> > +	__FR_ACT_MAX,
> > +};
> > +
> > +#define FR_ACT_MAX (__FR_ACT_MAX - 1)
> > +
> > +#endif
> 
> Shouldn't all these (struct fib_rule_hdr included) actually be defined
> in include/linux/rtnetlink.h?

We used to stuff everything into rtnetlink.h for no good reason. Having
independant include/linux/<subsystem>.h to export the interface to
userspace and include/net/<subsystem>.h to export the kernel interface
instead of contributing to the ifdef hell seems a lot cleaner to me.
