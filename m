From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net-next: Fix __inet_inherit_port() to correctly
 increment bsockets and num_owners
Date: Mon, 29 Nov 2010 14:17:46 +0100
Message-ID: <1291036666.3435.435.camel@edumazet-laptop>
References: <20101128230041.GA16269@ioremap.net>
	 <20101129123909.GA9286@ff.dom.local> <20101129125102.GA17736@ioremap.net>
	 <20101129131201.GB9286@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	Nagendra Tomar <tomer_iisc@yahoo.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:32810 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752564Ab0K2NRv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 08:17:51 -0500
Received: by wyb28 with SMTP id 28so4404723wyb.19
        for <netdev@vger.kernel.org>; Mon, 29 Nov 2010 05:17:50 -0800 (PST)
In-Reply-To: <20101129131201.GB9286@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 29 novembre 2010 =C3=A0 13:12 +0000, Jarek Poplawski a =C3=A9c=
rit :

> Evgeniy & Eric,
>=20
> But it's compared to the numer of available port numbers in
> inet_csk_get_port():
>=20
>      "if (atomic_read(&hashinfo->bsockets) > (high - low) + 1)"
>=20
> Can't you have bsockets higher than this with only one port used?
>=20

Because we store tuples, not only port information.

You can have many sockets bound on a single port.

This 'optimization' was only meaningful on a machine you make only
active connections, if you ask me...

Problem is, as soon as some passive connections are done, bsockets coun=
t
becomes wrong. The patch fixes this, thats all.



