From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: use kfree_rcu() in netlink_release()
Date: Thu, 18 Oct 2012 15:36:16 -0400 (EDT)
Message-ID: <20121018.153616.732430567959014097.davem@davemloft.net>
References: <1350566515.26103.1549.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, marcheu@google.com, kliegs@google.com,
	sleffler@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53648 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752533Ab2JRTgT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2012 15:36:19 -0400
In-Reply-To: <1350566515.26103.1549.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 18 Oct 2012 15:21:55 +0200

> From: Eric Dumazet <edumazet@google.com>
>=20
> On some suspend/resume operations involving wimax device, we have
> noticed some intermittent memory corruptions in netlink code.
>=20
> St=E9phane Marchesin tracked this corruption in netlink_update_listen=
ers()
> and suggested a patch.
>=20
> It appears netlink_release() should use kfree_rcu() instead of kfree(=
)
> for the listeners structure as it may be used by other cpus using RCU
> protection.
>=20
> netlink_release() must set to NULL the listeners pointer when
> it is about to be freed.
>=20
> Also have to protect netlink_update_listeners() and
> netlink_has_listeners() if listeners is NULL.
>=20
> Add a nl_deref_protected() lockdep helper to properly document which
> locks protects us.
>=20
> Reported-by: Jonathan Kliegman <kliegs@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable.
