From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] Do not listen if rtnl_send() fails in ip link
 iplink_have_newlink() test
Date: Wed, 11 Dec 2013 10:57:49 -0800
Message-ID: <20131211105749.1ee87844@nehalam.linuxnetplumber.net>
References: <1386766889-19062-1-git-send-email-ppisar@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: Petr =?UTF-8?B?UMOtc2HFmQ==?= <ppisar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:36779 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945Ab3LKS5y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 13:57:54 -0500
Received: by mail-pd0-f177.google.com with SMTP id q10so9993247pdj.22
        for <netdev@vger.kernel.org>; Wed, 11 Dec 2013 10:57:54 -0800 (PST)
In-Reply-To: <1386766889-19062-1-git-send-email-ppisar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 11 Dec 2013 14:01:29 +0100
Petr P=C3=ADsa=C5=99 <ppisar@redhat.com> wrote:

> If rtnl_send() fails in iplink_have_newlink() test, listening for
> response will result in indefinite hang. This can be demonstrated by
> "ip link show" while SELinux preventing from sending the RTM_NEWLINK
> over netlink.
>=20
> This patch checks for the return value as is done at all other
> rtnl_send() calls.
>=20
> Signed-off-by: Petr P=C3=ADsa=C5=99 <ppisar@redhat.com>
> ---
>  ip/iplink.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/ip/iplink.c b/ip/iplink.c
> index 58b6c20..f7d9e17 100644
> --- a/ip/iplink.c
> +++ b/ip/iplink.c
> @@ -178,8 +178,8 @@ static int iplink_have_newlink(void)
>  		req.n.nlmsg_type =3D RTM_NEWLINK;
>  		req.i.ifi_family =3D AF_UNSPEC;
> =20
> -		rtnl_send(&rth, &req.n, req.n.nlmsg_len);
> -		rtnl_listen(&rth, accept_msg, NULL);
> +		if (rtnl_send(&rth, &req.n, req.n.nlmsg_len) >=3D 0)
> +			rtnl_listen(&rth, accept_msg, NULL);
>  	}
>  	return have_rtnl_newlink;
>  }

I think it should print an error messag, not silently ignore the send f=
ailure.
