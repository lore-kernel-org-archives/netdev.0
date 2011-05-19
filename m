From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH FINAL] SCTP: fix race between sctp_bind_addr_free() and
 sctp_bind_addr_conflict()
Date: Thu, 19 May 2011 21:58:21 +0200
Message-ID: <1305835101.3156.6.camel@edumazet-laptop>
References: <4DD575A1.4080405@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, vladislav.yasevich@hp.com,
	netdev@vger.kernel.org
To: Jacek Luczak <difrost.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:48422 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933926Ab1EST6Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 15:58:25 -0400
Received: by wya21 with SMTP id 21so2247795wya.19
        for <netdev@vger.kernel.org>; Thu, 19 May 2011 12:58:24 -0700 (PDT)
In-Reply-To: <4DD575A1.4080405@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 19 mai 2011 =C3=A0 21:55 +0200, Jacek Luczak a =C3=A9crit :
> During the sctp_close() call, we do not use rcu primitives to
> destroy the address list attached to the endpoint.  At the same
> time, we do the removal of addresses from this list before
> attempting to remove the socket from the port hash
>=20
> As a result, it is possible for another process to find the socket
> in the port hash that is in the process of being closed.  It then
> proceeds to traverse the address list to find the conflict, only
> to have that address list suddenly disappear without rcu() critical
> section.
>=20
> Fix issue by closing address list removal inside RCU critical
> section.
>=20
> Race can result in a kernel crash with general protection fault or
> kernel NULL pointer dereference:
>=20

> Signed-off-by: Jacek Luczak <luczak.jacek@gmail.com>
> Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> CC: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> ---
>  net/sctp/bind_addr.c |   10 ++++------
>  1 files changed, 4 insertions(+), 6 deletions(-)
>=20

Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>


