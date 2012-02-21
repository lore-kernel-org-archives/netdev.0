From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/6] sock: Introduce the SO_PEEK_OFF sock option
Date: Tue, 21 Feb 2012 18:45:50 +0100
Message-ID: <1329846350.18384.25.camel@edumazet-laptop>
References: <4F43D49E.3010401@parallels.com>
	 <4F43D4F6.6030104@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:64353 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752274Ab2BURpz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 12:45:55 -0500
Received: by wics10 with SMTP id s10so3670506wic.19
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2012 09:45:54 -0800 (PST)
In-Reply-To: <4F43D4F6.6030104@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 21 f=C3=A9vrier 2012 =C3=A0 21:31 +0400, Pavel Emelyanov a =C3=
=A9crit :
> This one specifies where to start MSG_PEEK-ing queue data from. When
> set to negative value means that MSG_PEEK works as ususally -- peeks
> from the head of the queue always.
>=20
> When some bytes are peeked from queue and the peeking offset is non
> negative it is moved forward so that the next peek will return next
> portion of data.
>=20
> When non-peeking recvmsg occurs and the peeking offset is non negativ=
e
> is is moved backward so that the next peek will still peek the proper
> data (i.e. the one that would have been picked if there were no non
> peeking recv in between).
>=20
> The offset is set using per-proto opteration to let the protocol hand=
le
> the locking issues and to check whether the peeking offset feature is
> supported by the protocol the socket belongs to.
>=20
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
>=20
> ---
>  include/asm-generic/socket.h |    1 +
>  include/linux/net.h          |    1 +
>  include/net/sock.h           |   25 +++++++++++++++++++++++++
>  net/core/sock.c              |   13 +++++++++++++
>  4 files changed, 40 insertions(+), 0 deletions(-)
>=20
> diff --git a/include/asm-generic/socket.h b/include/asm-generic/socke=
t.h
> index 49c1704..832c270 100644
> --- a/include/asm-generic/socket.h
> +++ b/include/asm-generic/socket.h
> @@ -66,5 +66,6 @@
>  #define SO_RXQ_OVFL             40
> =20
>  #define SO_WIFI_STATUS		41
> +#define SO_PEEK_OFF		42
>  #define SCM_WIFI_STATUS	SO_WIFI_STATUS

small note : should be moved down by one line, after SCM_WIFI_STATUS

Other than that,=20
