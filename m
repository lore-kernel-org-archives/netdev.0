From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ipv4: Restore accept_local behaviour in
 fib_validate_source()
Date: Fri, 22 Aug 2014 12:27:38 -0700 (PDT)
Message-ID: <20140822.122738.1664789537072791035.davem@davemloft.net>
References: <1408259994-31458-1-git-send-email-sebastien.barre@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, gregory.detal@uclouvain.be,
	christoph.paasch@uclouvain.be, hannes@redhat.com,
	sergei.shtylyov@cogentembedded.com
To: sebastien.barre@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53493 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751666AbaHVT1j convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 15:27:39 -0400
In-Reply-To: <1408259994-31458-1-git-send-email-sebastien.barre@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: S=E9bastien Barr=E9 <sebastien.barre@uclouvain.be>
Date: Sun, 17 Aug 2014 09:19:54 +0200

> Commit 7a9bc9b81a5b ("ipv4: Elide fib_validate_source() completely wh=
en possible.")
> introduced a short-circuit to avoid calling fib_validate_source when =
not
> needed. That change took rp_filter into account, but not accept_local=
=2E
> This resulted in a change of behaviour: with rp_filter and accept_loc=
al
> off, incoming packets with a local address in the source field should=
 be
> dropped.
>=20
> Here is how to reproduce the change pre/post 7a9bc9b81a5b commit:
> -configure the same IPv4 address on hosts A and B.
> -try to send an ARP request from B to A.
> -The ARP request will be dropped before that commit, but accepted and=
 answered
> after that commit.
>=20
> This adds a check for ACCEPT_LOCAL, to maintain full
> fib validation in case it is 0. We also leave __fib_validate_source()=
 earlier
> when possible, based on the same check as fib_validate_source(), once=
 the
> accept_local stuff is verified.
>=20
> Cc: Gregory Detal <gregory.detal@uclouvain.be>
> Cc: Christoph Paasch <christoph.paasch@uclouvain.be>
> Cc: Hannes Frederic Sowa <hannes@redhat.com>
> Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Signed-off-by: S=E9bastien Barr=E9 <sebastien.barre@uclouvain.be>

Applied.
