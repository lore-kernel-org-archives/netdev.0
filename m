From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: Fix register_vlan_dev() error path
Date: Tue, 17 Nov 2009 06:45:21 -0800 (PST)
Message-ID: <20091117.064521.97621798.davem@davemloft.net>
References: <4B01558F.5000306@gmail.com>
	<20091117.002037.229474882.davem@davemloft.net>
	<4B02B616.3020801@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kaber@trash.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33385
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751813AbZKQOpF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Nov 2009 09:45:05 -0500
In-Reply-To: <4B02B616.3020801@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 17 Nov 2009 15:41:26 +0100

> David Miller a =E9crit :
>=20
>> Eric, please make allocation failure cause the vlan_setup()
>> to fail and propagate -EFAULT back to the caller.
>=20
> Sure ! (You meant -ENOMEM probably...)

Indeed.

> [PATCH] vlan: Fix register_vlan_dev() error path
>=20
> In case register_netdevice() returns an error, and a new vlan_group w=
as
> allocated and inserted in vlan_group_hash[] we call vlan_group_free()=
 without
> deleting group from hash table. Future lookups can give infinite loop=
s or crashes.
>=20
> We must delete the vlan_group using RCU safe procedure.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Good catch, applied to net-2.6 and queued up for -stable.
