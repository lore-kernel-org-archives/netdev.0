From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-2.6] Re: rib_trie / Fix inflate_threshold_root.
	Now=15 size=11 bits
Date: Tue, 30 Jun 2009 07:09:29 +0000
Message-ID: <20090630070929.GB5589@ff.dom.local>
References: <20090629083315.GA4712@ff.dom.local> <4A488EB8.4070602@itcare.pl> <20090629104703.GC4712@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Robert Olsson <robert@robur.slu.se>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	"Jorge Boncompte [DTI2]" <jorge@dti2.net>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Robert Olsson <robert.olsson@its.uu.se>,
	Linux Network Development list <netdev@vger.kernel.org>
To: =?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:64614 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751110AbZF3HJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 03:09:33 -0400
Received: by fg-out-1718.google.com with SMTP id e12so603213fga.17
        for <netdev@vger.kernel.org>; Tue, 30 Jun 2009 00:09:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090629104703.GC4712@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 29, 2009 at 10:47:03AM +0000, Jarek Poplawski wrote:
> On Mon, Jun 29, 2009 at 11:51:52AM +0200, Pawe=B3 Staszewski wrote:
> > I apply this patch
> >
> > fib_triestats in attached file :)
>=20
> Great! But it would be nice to check if this (accidentally ;-) might
> fix the previous problem, so I attach below the patch with "manual
> RCU", which btw. (or even more important) should verify RCU use here.
>=20
> It should be applied on top of this last "Fix..., part3". And
> again: it's quite probable it can fail, so with caution, no hurry
> (it can wait for quiet time)...

Pawel, here is another try to check what's going on here, so just
like before, but this one on top of these 2 last working patches,
plus quite time... (Stats aren't necessary; if these are some doubts
let me know.)

Thanks,
Jarek P.
--------------------> (synchronize_rcu take 5)

diff -Nurp a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
--- a/net/ipv4/fib_trie.c	2009-06-29 10:00:14.000000000 +0000
+++ b/net/ipv4/fib_trie.c	2009-06-30 06:50:35.000000000 +0000
@@ -1036,6 +1036,7 @@ static void trie_rebalance(struct trie *
=20
 	rcu_assign_pointer(t->trie, (struct node *)tn);
 	tnode_free_flush();
+	synchronize_rcu();
=20
 	return;
 }
