From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [Patch net-next] ipv6: statically link
 register_inet6addr_notifier()
Date: Mon, 15 Apr 2013 13:09:30 +0200
Message-ID: <1366024170.8361.12.camel@jlt4.sipsolutions.net>
References: <1365952723-23295-1-git-send-email-amwang@redhat.com>
	 <CACraW2oiz27V0fvN2+hxP55hntiMT9QSJTqecjLAGrUXG6i+wA@mail.gmail.com>
	 (sfid-20130415_124006_755244_5F92EBF7)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	YOSHIFUJI Hidaki <yoshfuji@linux-ipv6.org>
To: Tomas Melin <tomas.melin@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:49240 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753884Ab3DOLJh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 07:09:37 -0400
In-Reply-To: <CACraW2oiz27V0fvN2+hxP55hntiMT9QSJTqecjLAGrUXG6i+wA@mail.gmail.com> (sfid-20130415_124006_755244_5F92EBF7)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-15 at 13:40 +0300, Tomas Melin wrote:
> On Sun, Apr 14, 2013 at 6:18 PM, Cong Wang <amwang@redhat.com> wrote:
> > From: Cong Wang <amwang@redhat.com>
> >
> > Tomas reported the following build error:
> >
> > net/built-in.o: In function `ieee80211_unregister_hw':
> > (.text+0x10f0e1): undefined reference to `unregister_inet6addr_notifier'
> > net/built-in.o: In function `ieee80211_register_hw':
> > (.text+0x10f610): undefined reference to `register_inet6addr_notifier'
> > make: *** [vmlinux] Error 1
> >
> > when built IPv6 as a module.
> >
> > So we have to statically link these symbols.
> >
> > Reported-by: Tomas Melin <tomas.melin@iki.fi>
> > Cc: Tomas Melin <tomas.melin@iki.fi>
> > Cc: "David S. Miller" <davem@davemloft.net>
> > Cc: YOSHIFUJI Hidaki <yoshfuji@linux-ipv6.org>
> > Signed-off-by: Cong Wang <amwang@redhat.com>
> 
> 
> This fixes the issue. Added Johannes Berg for information.

> > +++ b/net/ipv6/addrconf.c

> > -EXPORT_SYMBOL(register_inet6addr_notifier);

> > +++ b/net/ipv6/addrconf_core.c
> > @@ -78,3 +78,22 @@ int __ipv6_addr_type(const struct in6_addr *addr)
> >  }
> >  EXPORT_SYMBOL(__ipv6_addr_type);
> >
> > +static ATOMIC_NOTIFIER_HEAD(inet6addr_chain);
> > +
> > +int register_inet6addr_notifier(struct notifier_block *nb)
> > +{
> > +       return atomic_notifier_chain_register(&inet6addr_chain, nb);
> > +}
> > +EXPORT_SYMBOL(register_inet6addr_notifier);

That works for me, but it seems pretty pointless to have this API?
Anyway, let me know if you want to apply this patch, then I'll drop mine
and also remove the ifdefs from mac80211.

johannes
