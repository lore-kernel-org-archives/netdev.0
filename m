From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] get rid of read/write lock in gen_estimator
Date: Mon, 28 Sep 2009 12:42:26 -0700 (PDT)
Message-ID: <20090928.124226.27020404.davem@davemloft.net>
References: <20090928113855.52eab44b@nehalam>
	<4AC10574.6070406@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37939
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752747AbZI1TmH convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Sep 2009 15:42:07 -0400
In-Reply-To: <4AC10574.6070406@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 28 Sep 2009 20:50:28 +0200

> Stephen Hemminger a =E9crit :
>> Don't need a read/write lock here sinc there already is a spin lock =
that
>> is being acquired.
>>=20
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
 ...
>> @@ -270,9 +265,9 @@ void gen_kill_estimator(struct gnet_stat
>>  	while ((e =3D gen_find_node(bstats, rate_est))) {
>>  		rb_erase(&e->node, &est_root);
>> =20
>> -		write_lock_bh(&est_lock);
>> +		spin_lock(e->stats_lock);
>=20
> Are you sure _bh() variant is not needed here ?

Right, that need to be fixed to be spin_lock_bh() and spin_unlock_bh()
in the next hunk.
