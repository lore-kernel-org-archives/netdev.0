From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: core: scm: fix information leak to userland
Date: Sat, 30 Oct 2010 16:33:25 +0200
Message-ID: <1288449205.2680.968.camel@edumazet-laptop>
References: <1288448796-6147-1-git-send-email-segooon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kernel-janitors@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Tejun Heo <tj@kernel.org>,
	"Serge E. Hallyn" <serge@hallyn.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Vasiliy Kulikov <segooon@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57807 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753702Ab0J3Odj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Oct 2010 10:33:39 -0400
In-Reply-To: <1288448796-6147-1-git-send-email-segooon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 30 octobre 2010 =C3=A0 18:26 +0400, Vasiliy Kulikov a =C3=A9c=
rit :
> Structure cmsghdr is copied to userland with padding bytes
> unitialized on architectures where __kernel_size_t is unsigned long.
> It leads to leaking of contents of kernel stack memory.
>=20
> Signed-off-by: Vasiliy Kulikov <segooon@gmail.com>
> ---
>  Compile tested.
>=20
>  net/core/scm.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/core/scm.c b/net/core/scm.c
> index 413cab8..a4a9b70 100644
> --- a/net/core/scm.c
> +++ b/net/core/scm.c
> @@ -233,6 +233,7 @@ int put_cmsg(struct msghdr * msg, int level, int =
type, int len, void *data)
>  		msg->msg_flags |=3D MSG_CTRUNC;
>  		cmlen =3D msg->msg_controllen;
>  	}
> +	memset(&cmhdr, 0, sizeof(cmhdr));
>  	cmhdr.cmsg_level =3D level;
>  	cmhdr.cmsg_type =3D type;
>  	cmhdr.cmsg_len =3D cmlen;


???

struct cmsghdr {
        __kernel_size_t cmsg_len;       /* data byte count, including h=
dr */
        int             cmsg_level;     /* originating protocol */
        int             cmsg_type;      /* protocol-specific type */
};

Could you explain where are the padding bytes ?



