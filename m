From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [RFC PATCH V4 02/13] netback: add module unload function.
Date: Thu, 2 Feb 2012 17:28:30 +0000
Message-ID: <1328203710.5553.94.camel@leeds.uk.xensource.com>
References: <1328201363-13915-1-git-send-email-wei.liu2@citrix.com>
	 <1328201363-13915-3-git-send-email-wei.liu2@citrix.com>
	 <1328202524.11534.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"Ian Campbell" <Ian.Campbell@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:46157 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932249Ab2BBR2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 12:28:12 -0500
In-Reply-To: <1328202524.11534.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-02-02 at 17:08 +0000, Eric Dumazet wrote:
> Le jeudi 02 f=C3=A9vrier 2012 =C3=A0 16:49 +0000, Wei Liu a =C3=A9cri=
t :
> > Enables users to unload netback module.
> >=20
> > Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> > Tested-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> > Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> > ---
> >  drivers/net/xen-netback/common.h  |    1 +
> >  drivers/net/xen-netback/netback.c |   14 ++++++++++++++
> >  drivers/net/xen-netback/xenbus.c  |    5 +++++
> >  3 files changed, 20 insertions(+), 0 deletions(-)
> >=20
> > diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-net=
back/common.h
> > index 288b2f3..372c7f5 100644
> > --- a/drivers/net/xen-netback/common.h
> > +++ b/drivers/net/xen-netback/common.h
> > @@ -126,6 +126,7 @@ void xenvif_get(struct xenvif *vif);
> >  void xenvif_put(struct xenvif *vif);
> > =20
> >  int xenvif_xenbus_init(void);
> > +void xenvif_xenbus_exit(void);
> > =20
> >  int xenvif_schedulable(struct xenvif *vif);
> > =20
> > diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-ne=
tback/netback.c
> > index d11205f..3059684 100644
> > --- a/drivers/net/xen-netback/netback.c
> > +++ b/drivers/net/xen-netback/netback.c
> > @@ -1670,5 +1670,19 @@ failed_init:
> > =20
> >  module_init(netback_init);
> > =20
>=20
> While reviewing this code, I can see current netback_init() is buggy.
>=20
> It assumes all online cpus xen_netbk_group_nr are numbered from 0 to
> xen_netbk_group_nr-1
>=20
> This is not right.
>=20

You're right about this.

But this part is destined to get wiped out (in the very near future?) -=
-
see following patches. So I don't think it is worthy to fix this.


Wei.

> Instead of using :
>=20
> xen_netbk =3D vzalloc(sizeof(struct xen_netbk) * xen_netbk_group_nr);
>=20
> You should use a percpu variable to get proper NUMA properties.
>=20
> And instead of looping like :
>=20
> for (group =3D 0; group < xen_netbk_group_nr; group++) {
>=20
> You must use :
>=20
> for_each_online_cpu(cpu) {
> 	...
> }
>=20
> [ and also use kthread_create_on_node() instead of kthread_create() ]
>=20
>=20
>=20
