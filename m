From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [PATCH 2/8] dccp: use limited socket backlog
Date: Wed, 03 Mar 2010 15:43:48 +0800
Message-ID: <1267602228.2370.64.camel@debian>
References: <1267598111-12503-1-git-send-email-yi.zhu@intel.com>
	 <1267598111-12503-2-git-send-email-yi.zhu@intel.com>
	 <1267599387.2839.89.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:47546 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751022Ab0CCHmD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Mar 2010 02:42:03 -0500
In-Reply-To: <1267599387.2839.89.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-03-03 at 14:56 +0800, Eric Dumazet wrote:
> Le mercredi 03 mars 2010 =C3=A0 14:35 +0800, Zhu Yi a =C3=A9crit :
> > Make dccp adapt to the limited socket backlog change.
> >=20
> > Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
> > Signed-off-by: Zhu Yi <yi.zhu@intel.com>
> > ---
> >  net/dccp/minisocks.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> >=20
> > diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
> > index af226a0..0d508c3 100644
> > --- a/net/dccp/minisocks.c
> > +++ b/net/dccp/minisocks.c
> > @@ -254,7 +254,7 @@ int dccp_child_process(struct sock *parent, str=
uct sock *child,
> >  		 * in main socket hash table and lock on listening
> >  		 * socket does not protect us more.
> >  		 */
> > -		sk_add_backlog(child, skb);
> > +		__sk_add_backlog(child, skb);
> >  	}
> > =20
> >  	bh_unlock_sock(child);
>=20
> I dont understand this patch.
>=20
> You make dccp vulnerable to memory exhaustion, I thought you wanted t=
o
> solve this problem.
>=20
> It should therefore be named "dccp: use unlimited socket backlog"
>=20
> (And this sounds not so sexy :) )

dccp uses sk_receive_skb() which calls sk_add_backlog() that I fixed in
the first patch. This patch here handles a different case, when the
parent sk is in the LISTEN state and we want the child to process the
packet. Should the backlog limit be applied here? I'm waiting for
comments.

Thanks,
-yi


