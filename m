From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] Add ability to register class interfaces for network
 class
Date: Wed, 27 Oct 2004 08:59:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041027085906.665d0125@guest-251-240.pdx.osdl.net>
References: <20041026183526.GA23535@two.research.nokia.com>
	<20041026184838.GB16621@infradead.org>
	<20041026205239.GA23825@two.research.nokia.com>
	<20041027111317.GA27240@infradead.org>
	<417F86F8.6020004@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: ext ext Christoph Hellwig <hch@infradead.org>, davem@davemloft.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Timo =?ISO-8859-1?B?VGVy5HM=?= <ext-timo.teras@nokia.com>
In-Reply-To: <417F86F8.6020004@nokia.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 27 Oct 2004 14:31:04 +0300
Timo Ter=E4s <ext-timo.teras@nokia.com> wrote:

> ext ext Christoph Hellwig wrote:
> >>I pointed out the reason why I need it: to add an attribute:
> >>/sys/class/net/<interface>/<new_attribute>. Others might want to do t=
his
> >>too.
> >>
> >>Also the interface subsystem is used in many places (eg. i2o) to crea=
te
> >>all the sysfs entries. Maybe it'd be useful to do in net class as wel=
l.
> >>And if'd make separate interfaces for standard attributes and wireles=
s
> >>attributes. That way you'd get rid of the #ifdefs of WIRELESS_EXT in
> >>net-sysfs.c.
> >>
> >>On the other hand you didn't answer my question: why the
> >>interface registration should not be possible?
> >>Documentation/driver-model/interface.txt states that this is exactly =
the
> >>thing it should be used for.
> >=20
> > Because we don't add interfaces for the sake of it. You still haven't=
 show
> > the user that wants this.  i you presented a sane user the review wou=
ld be
> > quite different.

The Ethernet bridge code creates attribute groups in several places
without additional interfaces.  How hard is it to do:

int br_sysfs_addbr(struct net_device *dev)
{
	struct kobject *brobj =3D &dev->class_dev.kobj;
	struct net_bridge *br =3D netdev_priv(dev);
	int err;

	err =3D sysfs_create_group(brobj, &bridge_group);
	if (err) {
		pr_info("%s: can't create group %s/%s\n",
			__FUNCTION__, dev->name, bridge_group.name);
		goto out1;
	}
