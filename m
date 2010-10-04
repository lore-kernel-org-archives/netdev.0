From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] AF_UNIX: Implement SO_TIMESTAMP and SO_TIMETAMPNS on
 Unix sockets
Date: Mon, 04 Oct 2010 20:09:49 +0200
Message-ID: <1286215789.2381.2.camel@edumazet-laptop>
References: <20101004190049.783f14ab@chocolatine.cbg.collabora.co.uk>
	 <1286215294-29166-1-git-send-email-alban.crequy@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lennart Poettering <lennart@poettering.net>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Alban Crequy <alban.crequy@collabora.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1286215294-29166-1-git-send-email-alban.crequy@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 04 octobre 2010 =C3=A0 19:01 +0100, Alban Crequy a =C3=A9crit =
:
> Userspace applications can already request to receive timestamps with=
:
> setsockopt(sockfd, SOL_SOCKET, SO_TIMESTAMP, ...)
>=20
> Although setsockopt() returns zero (success), timestamps are not adde=
d to the
> ancillary data. This patch fixes that on SOCK_DGRAM and SOCK_SEQPACKE=
T Unix
> sockets.
>=20
> Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
> ---
>  net/unix/af_unix.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 617bea4..bca0c1e 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -1697,6 +1697,9 @@ static int unix_dgram_recvmsg(struct kiocb *ioc=
b, struct socket *sock,
>  	if (err)
>  		goto out_free;
> =20
> +	if (sock_flag(sk, SOCK_RCVTSTAMP))
> +		__sock_recv_timestamp(msg, sk, skb);
> +
>  	if (!siocb->scm) {
>  		siocb->scm =3D &tmp_scm;
>  		memset(&tmp_scm, 0, sizeof(tmp_scm));

Hmm, but how is set skb->tstamp ?

I think its zero at this point, so __sock_recv_timestamp() use current
time, not time of send().

gettimeofday() might be better/cheaper :)
