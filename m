From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH net-next v10 03/11] ipv6: export a stub for IPv6 symbols
 used by vxlan
Date: Fri, 30 Aug 2013 15:47:47 +0800
Message-ID: <1377848867.2591.5.camel@cr0>
References: <1377667379-2315-1-git-send-email-amwang@redhat.com>
	 <1377667379-2315-4-git-send-email-amwang@redhat.com>
	 <20130828091208.4bcaedcf@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11083 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751995Ab3H3Hr4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Aug 2013 03:47:56 -0400
In-Reply-To: <20130828091208.4bcaedcf@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-08-28 at 09:12 -0700, Stephen Hemminger wrote:
> On Wed, 28 Aug 2013 13:22:51 +0800
> Cong Wang <amwang@redhat.com> wrote:
> 
> > +struct ipv6_stub {
> > +	int (*ipv6_sock_mc_join)(struct sock *sk, int ifindex,
> > +				 const struct in6_addr *addr);
> > +	int (*ipv6_sock_mc_drop)(struct sock *sk, int ifindex,
> > +				 const struct in6_addr *addr);
> > +	int (*ipv6_dst_lookup)(struct sock *sk, struct dst_entry **dst,
> > +				struct flowi6 *fl6);
> > +	void (*udpv6_encap_enable)(void);
> > +};
> > +extern const struct ipv6_stub *ipv6_stub __read_mostly;
> > +
> 
> Since IPv6 really can't ever be safely unloaded. why not:
>  * admit that, and get rid of ipv6_module exit.
>  * then this stub can be a static const table.
> 
> You see virtual function tables that are writeable are potential malware
> targets, although eliminating all of them is impossible, I hate to
> see adding new ones.

I think getting rid of ipv6 exit deserves another thread for discussion,
not in this thread. Actually I raised same question before, but no one
replied me. If you want, I can send another patch for it after this
patchset gets merged.

Thanks!
