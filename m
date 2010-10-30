From: Vasiliy Kulikov <segooon@gmail.com>
Subject: Re: [PATCH] net: core: scm: fix information leak to userland
Date: Sat, 30 Oct 2010 18:50:42 +0400
Message-ID: <20101030145042.GB25135@albatros>
References: <1288448796-6147-1-git-send-email-segooon@gmail.com>
 <1288449205.2680.968.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kernel-janitors@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Tejun Heo <tj@kernel.org>,
	"Serge E. Hallyn" <serge@hallyn.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:50481 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754307Ab0J3Ous (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Oct 2010 10:50:48 -0400
Content-Disposition: inline
In-Reply-To: <1288449205.2680.968.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 30, 2010 at 16:33 +0200, Eric Dumazet wrote:
> Le samedi 30 octobre 2010 =E0 18:26 +0400, Vasiliy Kulikov a =E9crit =
:
> > Structure cmsghdr is copied to userland with padding bytes
> > unitialized on architectures where __kernel_size_t is unsigned long=
=2E
> > It leads to leaking of contents of kernel stack memory.
> >=20
> > Signed-off-by: Vasiliy Kulikov <segooon@gmail.com>
> > ---
> >  Compile tested.
> >=20
> >  net/core/scm.c |    1 +
> >  1 files changed, 1 insertions(+), 0 deletions(-)
> >=20
> > diff --git a/net/core/scm.c b/net/core/scm.c
> > index 413cab8..a4a9b70 100644
> > --- a/net/core/scm.c
> > +++ b/net/core/scm.c
> > @@ -233,6 +233,7 @@ int put_cmsg(struct msghdr * msg, int level, in=
t type, int len, void *data)
> >  		msg->msg_flags |=3D MSG_CTRUNC;
> >  		cmlen =3D msg->msg_controllen;
> >  	}
> > +	memset(&cmhdr, 0, sizeof(cmhdr));
> >  	cmhdr.cmsg_level =3D level;
> >  	cmhdr.cmsg_type =3D type;
> >  	cmhdr.cmsg_len =3D cmlen;
>=20
>=20
> ???
>=20
> struct cmsghdr {
>         __kernel_size_t cmsg_len;       /* data byte count, including=
 hdr */
>         int             cmsg_level;     /* originating protocol */
>         int             cmsg_type;      /* protocol-specific type */
> };
>=20
> Could you explain where are the padding bytes ?

Ah, sorry, nowhere :)  int is stored quite OK after long.  Please ignor=
e this patch.

Thanks,

--=20
Vasiliy
