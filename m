From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/5 net-next] cnic: Randomize initial TCP port for
 iSCSI connections
Date: Fri, 10 Jun 2011 06:39:27 +0200
Message-ID: <1307680767.3210.5.camel@edumazet-laptop>
References: <1307597376-5379-1-git-send-email-mchan@broadcom.com>
	 <1307597376-5379-2-git-send-email-mchan@broadcom.com>
	 <1307597376-5379-3-git-send-email-mchan@broadcom.com>
	 <20110609082722.492b46b5@nehalam.ftrdhcpuser.net>
	 <1307668080.14980.13.camel@HP1>
	 <20110609210157.6a1f016b@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Chan <mchan@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eddie Wai <eddie.wai@broadcom.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:61709 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750733Ab1FJEjd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 00:39:33 -0400
Received: by wya21 with SMTP id 21so1587998wya.19
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2011 21:39:32 -0700 (PDT)
In-Reply-To: <20110609210157.6a1f016b@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 09 juin 2011 =C3=A0 21:01 -0700, Stephen Hemminger a =C3=A9cri=
t :
> On Thu, 9 Jun 2011 18:08:00 -0700
> "Michael Chan" <mchan@broadcom.com> wrote:
>=20
> >=20
> > On Thu, 2011-06-09 at 08:27 -0700, Stephen Hemminger wrote:
> > > On Wed, 8 Jun 2011 22:29:34 -0700
> > > "Michael Chan" <mchan@broadcom.com> wrote:
> > >=20
> > > >  static int cnic_cm_alloc_mem(struct cnic_dev *dev)
> > > >  {
> > > >  	struct cnic_local *cp =3D dev->cnic_priv;
> > > > +	u32 port_id;
> > > > =20
> > > >  	cp->csk_tbl =3D kzalloc(sizeof(struct cnic_sock) * MAX_CM_SK_=
TBL_SZ,
> > > >  			      GFP_KERNEL);
> > > >  	if (!cp->csk_tbl)
> > > >  		return -ENOMEM;
> > > > =20
> > > > +	get_random_bytes(&port_id, sizeof(port_id));
> > >=20
> > > I think random32() or it's alias net_random() would be sufficient
> > > for your needs here.
> > >=20
> >=20
> > random32() is pseudo random so we can get the same number after reb=
oot,
> > right?  One scenario is that we may be booting from an iSCSI target=
, but
> > due to some failure, the user may be rebooting multiple times rapid=
ly.
> > We want to use a different port during each boot.
>=20
> random32 is seeded off get_random_bytes at boot.

cnic_cm_alloc_mem() is apparently called one time per boot, it seems OK
to call get_random_bytes() in this case ?



