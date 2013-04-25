From: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Subject: Re: [PATCH] net: tun: release the reference of tun device in tun_recvmsg
Date: Thu, 25 Apr 2013 17:04:42 +0200
Message-ID: <201304251704.42257.a.miskiewicz@gmail.com>
References: <201304250822.38944.a.miskiewicz@gmail.com> <1366876763-2671-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jasowang@redhat.com
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:36287 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753544Ab3DYPEp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 11:04:45 -0400
Received: by mail-ea0-f174.google.com with SMTP id z16so1307978ead.33
        for <netdev@vger.kernel.org>; Thu, 25 Apr 2013 08:04:44 -0700 (PDT)
In-Reply-To: <1366876763-2671-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 25 of April 2013, Gao feng wrote:
> We forget to release the reference of tun device in tun_recvmsg.
> bug introduced in commit 54f968d6efdbf7dec36faa44fc11f01b0e4d1990
> (tuntap: move socket to tun_file)

Hm, still hitting the problem even with the patch - dmesg:

http://pastebin.com/iSm0QJVY


>=20
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> ---
>  drivers/net/tun.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 0c9df2f..dcd0c19 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1471,14 +1471,17 @@ static int tun_recvmsg(struct kiocb *iocb, st=
ruct
> socket *sock, if (!tun)
>  		return -EBADFD;
>=20
> -	if (flags & ~(MSG_DONTWAIT|MSG_TRUNC))
> -		return -EINVAL;
> +	if (flags & ~(MSG_DONTWAIT|MSG_TRUNC)) {
> +		ret =3D -EINVAL;
> +		goto out;
> +	}
>  	ret =3D tun_do_read(tun, tfile, iocb, m->msg_iov, total_len,
>  			  flags & MSG_DONTWAIT);
>  	if (ret > total_len) {
>  		m->msg_flags |=3D MSG_TRUNC;
>  		ret =3D flags & MSG_TRUNC ? ret : total_len;
>  	}
> +out:
>  	tun_put(tun);
>  	return ret;
>  }


--=20
Arkadiusz Mi=C5=9Bkiewicz, arekm / maven.pl
