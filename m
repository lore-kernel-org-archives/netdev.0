From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3 Ver2] tcp: Slightly optimize tcp_sendmsg
Date: Wed, 23 Dec 2009 14:16:06 -0800 (PST)
Message-ID: <20091223.141606.39185234.davem@davemloft.net>
References: <20091210171652.20777.79982.sendpatchset@localhost.localdomain>
	<20091210171659.20777.67516.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42923
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757463AbZLWWQE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2009 17:16:04 -0500
In-Reply-To: <20091210171659.20777.67516.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krishna Kumar <krkumar2@in.ibm.com>
Date: Thu, 10 Dec 2009 22:46:59 +0530

> From: Krishna Kumar <krkumar2@in.ibm.com>
>=20
> Slightly optimize tcp_sendmsg since NETIF_F_SG is used many
> times iteratively in the loop. The only other modification is
> to change:
> 			} else if (i =3D=3D MAX_SKB_FRAGS ||
> 				   (!i &&
> 				   !(sk->sk_route_caps & NETIF_F_SG))) {
> 	to:
> 			} else if (i =3D=3D MAX_SKB_FRAGS || !sg) {
>=20
> The reason why this change is correct: this code (other than
> the MAX_SKB_FRAGS case) executes only due to the else part
> of: "if (skb_tailroom(skb) > 0) {" - i.e. there was no space
> in the skb to put the data inline. Hence SG is false is a
> sufficient condition, and there is no way a fragment can be
> added to the skb.
>=20
> Changelog:
> 	- Added the above explanation for the change
>=20
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> Acked-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
