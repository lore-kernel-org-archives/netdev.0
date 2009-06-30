From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-2.6] Re: rib_trie / Fix inflate_threshold_root.
	Now=15 size=11 bits
Date: Tue, 30 Jun 2009 22:14:22 +0200
Message-ID: <20090630201422.GA3026@ami.dom.local>
References: <20090629083315.GA4712@ff.dom.local> <4A488EB8.4070602@itcare.pl> <20090629105820.GD4712@ff.dom.local> <20090630.124849.167332569.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: pstaszewski@itcare.pl, robert@robur.slu.se,
	Robert.Olsson@data.slu.se, jorge@dti2.net, dada1@cosmosbay.com,
	robert.olsson@its.uu.se, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:51602 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752863AbZF3UOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 16:14:53 -0400
Received: by bwz25 with SMTP id 25so111246bwz.37
        for <netdev@vger.kernel.org>; Tue, 30 Jun 2009 13:14:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090630.124849.167332569.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 30, 2009 at 12:48:49PM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Mon, 29 Jun 2009 10:58:20 +0000
>=20
> > On Mon, Jun 29, 2009 at 11:51:52AM +0200, Pawe=B3 Staszewski wrote:
> >> I apply this patch
> >>
> >> fib_triestats in attached file :)
> >>
> >>> ------------------->
> >>> ipv4: Fix fib_trie rebalancing, part 3
> >>>
> >>> Alas current delaying of freeing old tnodes by RCU in trie_rebala=
nce
> >>> is still not enough because we can free a top tnode before updati=
ng a
> >>> t->trie pointer.
> >>>
> >>> Reported-by: Pawel Staszewski <pstaszewski@itcare.pl>
> >>> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> >>> ---
> >=20
> > David, I guess you could add:
> >=20
> > Tested-by: Pawel Staszewski <pstaszewski@itcare.pl>
>=20
> Done, and applied, thanks Jarek.

Btw., a little comment: there are still some issues while trying to
reclaim memory after synchronize_rcu, which means the algorithm is
buggy, or RCU use is still buggy, or maybe some timing because of
synchronize_rcu. Anyway, fib_trie still seems to be safe only with
CONFIG_PREEMPT_NONE, so I have no idea how this should be fixed in
-stables (or why people don't report more this BUG in 2.6.30)...

Thanks,
Jarek P.
