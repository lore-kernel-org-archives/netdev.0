From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 6/6] Netfilter: xt_LOG: Add timestamp support
Date: Wed, 07 Mar 2012 07:40:46 -0800
Message-ID: <1331134846.2474.73.camel@edumazet-laptop>
References: <1330989588-26833-1-git-send-email-richard@nod.at>
	 <1330989588-26833-7-git-send-email-richard@nod.at>
	 <20120307152910.GA7044@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Richard Weinberger <richard@nod.at>, jengelh@medozas.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, rostedt@goodmis.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120307152910.GA7044@1984>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 07 mars 2012 =C3=A0 16:29 +0100, Pablo Neira Ayuso a =C3=A9=
crit :
> On Tue, Mar 06, 2012 at 12:19:48AM +0100, Richard Weinberger wrote:
> > Using XT_LOG_ADD_TIMESTAMP it is possible to have a timestamp
> > directly in the log message.
> >=20
> > Signed-off-by: Richard Weinberger <richard@nod.at>
> > ---
> >  include/linux/netfilter/xt_LOG.h |    3 ++-
> >  net/netfilter/xt_LOG.c           |    8 ++++++++
> >  2 files changed, 10 insertions(+), 1 deletions(-)
> >=20
> > diff --git a/include/linux/netfilter/xt_LOG.h b/include/linux/netfi=
lter/xt_LOG.h
> > index 8ac25e0..9361374 100644
> > --- a/include/linux/netfilter/xt_LOG.h
> > +++ b/include/linux/netfilter/xt_LOG.h
> > @@ -8,7 +8,8 @@
> >  #define XT_LOG_UID		0x08	/* Log UID owning local socket */
> >  #define XT_LOG_NFLOG		0x10	/* Unsupported, don't reuse */
> >  #define XT_LOG_MACDECODE	0x20	/* Decode MAC header */
> > -#define XT_LOG_MASK		0x2f
> > +#define XT_LOG_ADD_TIMESTAMP	0x40    /* Add a timestamp */
> > +#define XT_LOG_MASK		0x6f
> > =20
> >  struct xt_log_info {
> >          unsigned char level;
> > diff --git a/net/netfilter/xt_LOG.c b/net/netfilter/xt_LOG.c
> > index f75f2d7..23db206 100644
> > --- a/net/netfilter/xt_LOG.c
> > +++ b/net/netfilter/xt_LOG.c
> > @@ -499,6 +499,14 @@ log_packet_common(struct sbuff *m,
> >  	if (loginfo->type =3D=3D NF_LOG_TYPE_LOG)
> >  		sb_add(m, "<%d>", loginfo->u.log.level);
> > =20
> > +	if (loginfo->u.log.logflags & XT_LOG_ADD_TIMESTAMP) {
> > +		struct timespec tv;
> > +
> > +		getnstimeofday(&tv);
> > +		sb_add(m, "TIMESTAMP=3D%li.%03u ", tv.tv_sec,
> > +			(unsigned int)tv.tv_nsec / NSEC_PER_MSEC);
>=20
> net/netfilter/xt_LOG.c: In function =E2=80=98log_packet_common=E2=80=99=
:
> net/netfilter/xt_LOG.c:507:4: warning: format =E2=80=98%u=E2=80=99 ex=
pects argument of
> type =E2=80=98unsigned int=E2=80=99, but argument 4 has type =E2=80=98=
long int=E2=80=99 [-Wformat]
>=20
> It has to be:
>=20
>                 sb_add(m, "TIMESTAMP=3D%li.%03u ", tv.tv_sec,
>                         (unsigned int)(tv.tv_nsec / NSEC_PER_MSEC));
>                                       ^                          ^
> I've fixed, no need to resend this patch.

This is why I submitted the "netfilter: ipt_LOG: add __printf() to
sb_add()" patch :)
