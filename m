From: Jon Masters <jonathan@jonmasters.org>
Subject: Re: PROBLEM with summary: Re: [PATCH] netfilter: per netns
 nf_conntrack_cachep
Date: Tue, 02 Feb 2010 12:23:01 -0500
Message-ID: <1265131381.2861.164.camel@tonnant>
References: <1264813832.2793.446.camel@tonnant>
	 <1264816634.2793.505.camel@tonnant> <1264816777.2793.510.camel@tonnant>
	 <1264834704.2919.3.camel@edumazet-laptop>
	 <1265016745.7499.144.camel@tonnant>
	 <b6fcc0a1002010136k7e78a998p31a9e7464c2e8d44@mail.gmail.com>
	 <1265019160.2848.14.camel@edumazet-laptop>
	 <b6fcc0a1002010225u4e74f9f0q633d73038234dc37@mail.gmail.com>
	 <1265023437.2848.30.camel@edumazet-laptop>
	 <1265035970.2848.50.camel@edumazet-laptop>
	 <b6fcc0a1002010658j4f52a9b8kf10e4bb07a2f1075@mail.gmail.com>
	 <1265036548.2848.55.camel@edumazet-laptop>
	 <1265108690.2861.118.camel@tonnant>  <1265110504.2861.135.camel@tonnant>
	 <1265129192.2861.141.camel@tonnant> <1265129903.2861.150.camel@tonnant>
	 <4B685B14.1040207@trash.net>  <1265130990.2953.176.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dallas.jonmasters.org ([72.29.103.172]:60643 "EHLO
	dallas.jonmasters.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756679Ab0BBRXU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 12:23:20 -0500
In-Reply-To: <1265130990.2953.176.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-02-02 at 18:16 +0100, Eric Dumazet wrote:
> Le mardi 02 f=C3=A9vrier 2010 =C3=A0 18:04 +0100, Patrick McHardy a =C3=
=A9crit :
>=20
> > Ah nice catch, that seems to be the problem. When the untracked
> > conntrack is already attached to an skb and thus has refcnt > 1
> > and we re-initalize the refcnt, it will get freed.
> >=20
> > The question is whether the ct_net pointer of the untracked conntra=
ck
> > is actually required. If so, we need one instance per namespace,
> > otherwise we can just move initialization and cleanup to the init_n=
et
> > init/cleanup functions. Alexey, do you happen to know this?
> >=20
>=20
> One untracked per netns seems the way to go, and move it outside of
> read_mostly area too, we obviously can modify its refcount frequently=
=2E..

Sure, that will work. Also, rather than just the NF_CT_ASSERT on the us=
e
count, maybe worth catching the specific case of trying to free the
untracked ct, but that's only if it's not a horrible fast path.

Anyway, thanks. If you want to send me a patch, I'll try it.

Jon.


