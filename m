From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v2 3/4] ip_tunnels: introduce
 ip6_tunnel_key_init
Date: Fri, 2 Oct 2015 07:58:45 +0200
Message-ID: <20151002075845.062e1eb5@griffin>
References: <cover.1443710454.git.jbenc@redhat.com>
	<bc6c2e24fd657871553a1b1ae8c999c8b9b151d8.1443710454.git.jbenc@redhat.com>
	<CALnjE+p2xtSTpPtPtiHgPZmAdiCzCQn3AnNKCffVe3cKVAk7hg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Jesse Gross <jesse@nicira.com>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40027 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750767AbbJBF6t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Oct 2015 01:58:49 -0400
In-Reply-To: <CALnjE+p2xtSTpPtPtiHgPZmAdiCzCQn3AnNKCffVe3cKVAk7hg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 1 Oct 2015 17:11:43 -0700, Pravin Shelar wrote:
> On Thu, Oct 1, 2015 at 7:44 AM, Jiri Benc <jbenc@redhat.com> wrote:
> > +static inline void ip_tunnel_key_init(struct ip_tunnel_key *key,
> > +                                     __be32 saddr, __be32 daddr,
> > +                                     u8 tos, u8 ttl,
> > +                                     __be16 tp_src, __be16 tp_dst,
> > +                                     __be64 tun_id, __be16 tun_flags)
> > +{
> > +       __ip_tunnel_key_init(key, tos, ttl, tp_src, tp_dst, tun_id,
> > +                            tun_flags);
> > +       key->u.ipv4.src = saddr;
> > +       key->u.ipv4.dst = daddr;
> > +       memset((unsigned char *)key + IP_TUNNEL_KEY_IPV4_PAD,
> > +              0, IP_TUNNEL_KEY_IPV4_PAD_LEN);
> neat: since IP_TUNNEL_KEY_IPV4_PAD not really IPv4 tunnel key padding
> anymore, This also needs to be renamed.

It is IPv4 address padding. It is used to zero out the part of the
union of IPv6 and IPv4 addresses that is not occupied by IPv4
addresses. The name was just too long to include "ADDR", too.

The original pad constant was renamed to IP_TUNNEL_KEY_SIZE, thus is
not referencing IPv4 anymore.

> otherwise looks good.
> 
> Acked-by: Pravin B Shelar <pshelar@nicira.com>

Thanks,

 Jiri

-- 
Jiri Benc
