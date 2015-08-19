From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 04/13] ip_tunnels: add IPv6 addresses to
 ip_tunnel_key
Date: Wed, 19 Aug 2015 10:09:30 +0200
Message-ID: <20150819100930.2dd9eb59@griffin>
References: <cover.1439929916.git.jbenc@redhat.com>
	<199ae8362eabd65661ab145e9bfc281c5f5470ad.1439929916.git.jbenc@redhat.com>
	<20150819003632.GA989@Alexeis-MacBook-Pro-2.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39589 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753191AbbHSIJe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 04:09:34 -0400
In-Reply-To: <20150819003632.GA989@Alexeis-MacBook-Pro-2.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 18 Aug 2015 17:36:32 -0700, Alexei Starovoitov wrote:
> please add commit message. +47 -32 cannot be empty.

The patch seemed rather trivial to me (it's basically "->key.ipv4_" to
"->keu.u.ipv4." conversion plus one new memset) but sure, I'll add a
few words.

It probably does not qualify as trivial if one can make a bug in it :-)

> > +/* Used to memset ipv4 address padding. */
> > +#define IP_TUNNEL_KEY_IPV4_PAD	offsetofend(struct ip_tunnel_key, u.ipv4.dst)
> > +#define IP_TUNNEL_KEY_IPV4_PAD_LEN				\
> > +	(FIELD_SIZEOF(struct ip_tunnel_key, u) - IP_TUNNEL_KEY_IPV4_PAD)
> > +
> >  struct ip_tunnel_key {
> >  	__be64			tun_id;
> > -	__be32			ipv4_src;
> > -	__be32			ipv4_dst;
> > +	union {
> > +		struct {
> > +			__be32	src;
> > +			__be32	dst;
> > +		} ipv4;
> > +		struct {
> > +			struct in6_addr src;
> > +			struct in6_addr dst;
> > +		} ipv6;
> > +	} u;
> ...
> > +	tun_info->key.u.ipv4.src = saddr;
> > +	tun_info->key.u.ipv4.dst = daddr;
> > +	memset((unsigned char *)&tun_info->key + IP_TUNNEL_KEY_IPV4_PAD,
> > +	       0, IP_TUNNEL_KEY_IPV4_PAD_LEN);
> 
> the math looks wrong.
> IP_TUNNEL_KEY_IPV4_PAD_LEN = sizeof(u) - offsetofend(u.ipv4.dst)
> 8 byte mistake?

Yes, thanks a lot for catching this.

 Jiri

-- 
Jiri Benc
