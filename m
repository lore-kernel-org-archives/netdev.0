From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx4_en: initialize cmd.context_lock spinlock
 earlier
Date: Wed, 15 Jun 2016 12:17:02 -0700 (PDT)
Message-ID: <20160615.121702.1781767790141170944.davem@davemloft.net>
References: <1465829425.7945.160.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, eugenia@mellanox.com, tariqt@mellanox.com,
	maze@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33309 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932428AbcFOTRG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 15:17:06 -0400
In-Reply-To: <1465829425.7945.160.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 13 Jun 2016 07:50:25 -0700

> From: Eric Dumazet <edumazet@google.com>
>=20
> Maciej =AFenczykowski reported lockdep warning a spinlock
> was not registered before being held in mlx4_cmd_wake_completions()
>=20
> cmd.context_lock initialization is not at the right place.
>=20
> 1) mlx4_cmd_use_events() can be called multiple times.
>    Calling spin_lock_init() on a live spinlock can lead
>    to hangs.
>=20
> 2) mlx4_cmd_wake_completions() can be called while lock
>    has not been initialized.
>    Lockdep complains, and current logic is not race prone.
>=20
> It seems better to move the initialization earlier in
> mlx4_load_one()
>=20
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Maciej =AFenczykowski <maze@google.com>

Applied.
