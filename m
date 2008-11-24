From: David Miller <davem@davemloft.net>
Subject: Re: net-next/unix: BUG: using smp_processor_id() in preemptible
Date: Sun, 23 Nov 2008 17:20:14 -0800 (PST)
Message-ID: <20081123.172014.78676422.davem@davemloft.net>
References: <Pine.LNX.4.64.0811221634370.10534@wrl-59.cs.helsinki.fi>
	<4928CECE.602@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57362
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751624AbYKXBUP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Nov 2008 20:20:15 -0500
In-Reply-To: <4928CECE.602@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <dada1@cosmosbay.com>
Date: Sun, 23 Nov 2008 04:32:30 +0100

> [PATCH] net: make sock_prot_inuse_add() preempt safe
>=20
> Ilpo J=E4rvinen reported that commit a8076d8db98de6da61394b2e942320e4=
612643ac
> (net: af_unix should update its inuse counter) was triggering
> a warning in smp_processor_id(), being called in a preemptible code.
>=20
> Fix is to make sock_prot_inuse_add() safe in this regard. This fix
> can be reverted when new percpu infrastructure is ready, allowing
> a cpu to safely do a increment/decrement on a percpu var.
>=20
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Eric, you added this bug by starting to use this interface in
situations where BH's were not disabled.

Ever existing use adhered to that rule.

If you therefore want to call this interface in new locations,
you have to make sure those locations follow the rule too.

Making it expensive for all the existing cases which were already
safe, is not the way to fix this.  And saying some future not-merged
change justifies this added cost is besides the point.

What is valid is getting rid of the BH disables you need to add
to net/unix/af_unix.c et al.'s call sites, once those percpu patches
are added.  Not the other way around.
