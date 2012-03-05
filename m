From: Roland Dreier <roland@purestorage.com>
Subject: Re: [PATCH net] mlx4_core: remove buggy sched_queue masking
Date: Mon, 5 Mar 2012 12:46:41 -0800
Message-ID: <CAL1RGDWAHNRK5paWzE1xKPCxgKMEQi65_ZD7p1Nk+TGNXsQ9aA@mail.gmail.com>
References: <4F54D3C1.8000902@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, amirv@mellanox.co.il
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog113.obsmtp.com ([74.125.245.94]:60895 "HELO
	na3sys010aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757455Ab2CEUrC convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2012 15:47:02 -0500
Received: by mail-pw0-f52.google.com with SMTP id uo15so7203886pbc.25
        for <netdev@vger.kernel.org>; Mon, 05 Mar 2012 12:47:01 -0800 (PST)
In-Reply-To: <4F54D3C1.8000902@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> =A0 =A0 =A0 =A0port =3D ((context->pri_path.sched_queue >> 6) & 1) + =
1;

This assignment of port seems to become dead code now...

> - =A0 =A0 =A0 if (dev->caps.port_type[port] =3D=3D MLX4_PORT_TYPE_ETH=
)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 context->pri_path.sched_queue =3D (cont=
ext->pri_path.sched_queue &
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 0xc3);
>
> =A0 =A0 =A0 =A0*(__be32 *) mailbox->buf =3D cpu_to_be32(optpar);
> =A0 =A0 =A0 =A0memcpy(mailbox->buf + 8, context, sizeof *context);
