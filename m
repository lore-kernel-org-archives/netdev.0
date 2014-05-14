From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: avoid dependency of net_get_random_once on
 nop patching
Date: Wed, 14 May 2014 00:37:55 -0400 (EDT)
Message-ID: <20140514.003755.1614849153032517878.davem@davemloft.net>
References: <1399841970-869-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, torvalds@linux-foundation.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47852 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751356AbaENEjW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 00:39:22 -0400
In-Reply-To: <1399841970-869-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sun, 11 May 2014 22:59:30 +0200

> net_get_random_once depends on the static keys infrastructure to patc=
h up
> the branch to the slow path during boot. This was realized by abusing=
 the
> static keys api and defining a new initializer to not enable the call
> site while still indicating that the branch point should get patched
> up. This was needed to have the fast path considered likely by gcc.
>=20
> The static key initialization during boot up normally walks through a=
ll
> the registered keys and either patches in ideal nops or enables the j=
ump
> site but omitted that step on x86 if ideal nops where already placed =
at
> static_key branch points. Thus net_get_random_once branches not alway=
s
> became active.
>=20
> This patch switches net_get_random_once to the ordinary static_key
> api and thus places the kernel fast path in the - by gcc considered -
> unlikely path.  Microbenchmarks on Intel and AMD x86-64 showed that
> the unlikely path actually beats the likely path in terms of cycle co=
st
> and that different nop patterns did not make much difference, thus th=
is
> switch should not be noticeable.
>=20
> Fixes: a48e42920ff38b ("net: introduce new macro net_get_random_once"=
)
> Reported-by: Tuomas R=E4s=E4nen <tuomasjjrasanen@tjjr.fi>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable, thanks.
