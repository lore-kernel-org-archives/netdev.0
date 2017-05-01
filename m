From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute2] iplink: add support for IFLA_CARRIER attribute
Date: Mon, 1 May 2017 09:16:37 -0700
Message-ID: <20170501091637.350e0ea7@xeon-e3>
References: <1493190519-5518-1-git-send-email-zhangshengju@cmss.chinamobile.com>
        <20170426080732.51f56b8c@xeon-e3>
        <002301d2bf20$6647b5c0$32d72140$@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: <netdev@vger.kernel.org>
To: =?UTF-8?B?5byg6IOc5Li+?= <zhangshengju@cmss.chinamobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33735 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752457AbdEAQQk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 12:16:40 -0400
Received: by mail-pf0-f174.google.com with SMTP id q20so22753853pfg.0
        for <netdev@vger.kernel.org>; Mon, 01 May 2017 09:16:40 -0700 (PDT)
In-Reply-To: <002301d2bf20$6647b5c0$32d72140$@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 27 Apr 2017 14:35:01 +0800
=E5=BC=A0=E8=83=9C=E4=B8=BE <zhangshengju@cmss.chinamobile.com> wrote:

> > -----Original Message-----
> > From: Stephen Hemminger [mailto:stephen@networkplumber.org]
> > Sent: Wednesday, April 26, 2017 11:08 PM
> > To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> > Cc: netdev@vger.kernel.org
> > Subject: Re: [iproute2] iplink: add support for IFLA_CARRIER attribute
> >=20
> > On Wed, 26 Apr 2017 15:08:39 +0800
> > Zhang Shengju <zhangshengju@cmss.chinamobile.com> wrote:
> >  =20
> > > Add support to set IFLA_CARRIER attribute.
> > >
> > > Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> > > ---
> > >  ip/iplink.c | 12 ++++++++++++
> > >  1 file changed, 12 insertions(+)
> > >
> > > diff --git a/ip/iplink.c b/ip/iplink.c index 866ad72..263bfdd 100644
> > > --- a/ip/iplink.c
> > > +++ b/ip/iplink.c
> > > @@ -72,6 +72,7 @@ void iplink_usage(void)
> > >  		"	                  [ allmulticast { on | off } ]\n"
> > >  		"	                  [ promisc { on | off } ]\n"
> > >  		"	                  [ trailers { on | off } ]\n"
> > > +		"	                  [ carrier { on | off } ]\n"
> > >  		"	                  [ txqueuelen PACKETS ]\n"
> > >  		"	                  [ name NEWNAME ]\n"
> > >  		"	                  [ address LLADDR ]\n"
> > > @@ -673,6 +674,17 @@ int iplink_parse(int argc, char **argv, struct =
=20
> > iplink_req *req, =20
> > >  				req->i.ifi_flags |=3D IFF_NOARP;
> > >  			else
> > >  				return on_off("arp", *argv);
> > > +		} else if (strcmp(*argv, "carrier") =3D=3D 0) {
> > > +			int carrier;
> > > +			NEXT_ARG();
> > > +			if (strcmp(*argv, "on") =3D=3D 0)
> > > +				carrier =3D 1;
> > > +			else if (strcmp(*argv, "off") =3D=3D 0)
> > > +				carrier =3D 0;
> > > +			else
> > > +				return on_off("carrier", *argv);
> > > +
> > > +			addattr8(&req->n, sizeof(*req), IFLA_CARRIER, =20
> > carrier); =20
> > >  		} else if (strcmp(*argv, "vf") =3D=3D 0) {
> > >  			struct rtattr *vflist;
> > > =20
> >=20
> > The general policy of ip link command is all options should be invertab=
le. =20
> Yes, so I add 'on' and 'off' subcommand to make sure that it can be
> invertable.
>=20
> > There are some VPN's that use this to save and restore state. So if you=
 =20
> add
> > an option to set something there should be similar output under the =20
> detailed
> > show command. =20
> Currently, "show command" already can display 'carrier' status. Such as:
>  dummy0: <NO-CARRIER...>
>=20

Applied.
