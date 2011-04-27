From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/4] ipv4: Sanitize and simplify
 ip_route_{connect,newports}()
Date: Wed, 27 Apr 2011 06:47:57 +0200
Message-ID: <1303879677.2699.45.camel@edumazet-laptop>
References: <20110426.151202.245387083.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42986 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750989Ab1D0EsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 00:48:03 -0400
Received: by wwa36 with SMTP id 36so1460855wwa.1
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2011 21:48:02 -0700 (PDT)
In-Reply-To: <20110426.151202.245387083.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 26 avril 2011 =C3=A0 15:12 -0700, David Miller a =C3=A9crit :
> These functions are used together as a unit for route resolution
> during connect().  They address the chicken-and-egg problem that
> exists when ports need to be allocated during connect() processing,
> yet such port allocations require addressing information from the
> routing code.
>=20
> It's currently more heavy handed than it needs to be, and in
> particular we allocate and initialize a flow object twice.
>=20
> Let the callers provide the on-stack flow object.  That way we only
> need to initialize it once in the ip_route_connect() call.
>=20
> Later, if ip_route_newports() needs to do anything, it re-uses that
> flow object as-is except for the ports which it updates before the
> route re-lookup.
>=20
> Also, describe why this set of facilities are needed and how it works
> in a big comment.
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>

Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>


