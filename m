From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: Re: [PATCH] Use dev_port for the ID of a network device.
Date: Tue, 1 Jul 2014 09:26:38 -0300
Message-ID: <20140701122637.GB1204@oc0268524204.ibm.com>
References: <1404160596-25859-1-git-send-email-cascardo@linux.vnet.ibm.com>
 <87egy54lwb.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp01.br.ibm.com ([32.104.18.85]:51634 "EHLO
	e24smtp01.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752804AbaGAM0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2014 08:26:44 -0400
Received: from /spool/local
	by e24smtp01.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Tue, 1 Jul 2014 09:26:42 -0300
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by d24dlp01.br.ibm.com (Postfix) with ESMTP id 63B13352006A
	for <netdev@vger.kernel.org>; Tue,  1 Jul 2014 08:26:35 -0400 (EDT)
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s61CQtfv3862780
	for <netdev@vger.kernel.org>; Tue, 1 Jul 2014 09:26:55 -0300
Received: from d24av04.br.ibm.com (localhost [127.0.0.1])
	by d24av04.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s61CQexp020894
	for <netdev@vger.kernel.org>; Tue, 1 Jul 2014 09:26:40 -0300
Content-Disposition: inline
In-Reply-To: <87egy54lwb.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 01, 2014 at 08:45:56AM +0200, Bj=F8rn Mork wrote:
> Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com> writes:
>=20
> > diff --git a/src/udev/udev-builtin-net_id.c b/src/udev/udev-builtin=
-net_id.c
> > index c80c30a..6de9c98 100644
> > --- a/src/udev/udev-builtin-net_id.c
> > +++ b/src/udev/udev-builtin-net_id.c
> > @@ -186,9 +186,14 @@ static int dev_pci_slot(struct udev_device *de=
v, struct netnames *names) {
> >                  return -ENOENT;
> > =20
> >          /* kernel provided multi-device index */
> > -        attr =3D udev_device_get_sysattr_value(dev, "dev_id");
> > -        if (attr)
> > +        attr =3D udev_device_get_sysattr_value(dev, "dev_port");
> > +        if (attr) {
> >                  dev_id =3D strtol(attr, NULL, 16);
> > +        } else {
> > +                attr =3D udev_device_get_sysattr_value(dev, "dev_i=
d");
> > +                if (attr)
> > +                        dev_id =3D strtol(attr, NULL, 16);
> > +        }
> > =20
> >          /* compose a name based on the raw kernel's PCI bus, slot =
numbers */
> >          s =3D names->pci_path;
>=20
> Note that the base of the new attribute is 10, not 16:
>=20
> bjorn@nemi:/usr/local/src/git/linux$ git grep dev_port net/core/
> net/core/net-sysfs.c:NETDEVICE_SHOW_RO(dev_port, fmt_dec);
> net/core/net-sysfs.c:   &dev_attr_dev_port.attr,
> bjorn@nemi:/usr/local/src/git/linux$ git grep dev_id net/core/
> net/core/net-sysfs.c:NETDEVICE_SHOW_RO(dev_id, fmt_hex);
> net/core/net-sysfs.c:   &dev_attr_dev_id.attr,
>=20
>=20
>=20
> Bj=F8rn
>=20

Thanks for noticing, I'll fix that.

Cascardo.
