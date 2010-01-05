From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: packet: option to only pass skb protocol
Date: Tue, 05 Jan 2010 20:27:21 +0100
Message-ID: <4B439299.1090205@gmail.com>
References: <20100105185732.GA30346@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:32788 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754224Ab0AET1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 14:27:47 -0500
In-Reply-To: <20100105185732.GA30346@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/01/2010 19:57, Michael S. Tsirkin a =E9crit :
> When sending packets with a packet socket it is often necessary to se=
t
> protocol in msg_name: otherwise the protocol field in the skb will no=
t
> be set correctly.  However, currently doing this also requires
> supplying the interface index.
>=20
> The following patch makes it possible to avoid supplying the interfac=
e
> index by interpreting index 0 as "use device this socket is bound to"=
=2E
>=20

Patch is correct, but I dont understand why zero initialization by call=
er
is any better then supplying ifindex (known when socket was bound to de=
vice ?)

To avoid one syscall at socket setup (to get ifindex from dev name),
you prefer to add a test/branch at each send() syscall...

Am I missing something ?
