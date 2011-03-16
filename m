From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: [PATCH V4] Export ACPI _DSM provided firmware instance number
 and string name to sysfs
Date: Wed, 16 Mar 2011 10:41:54 -0700
Message-ID: <20110316104154.77bd9d58@jbarnes-desktop>
References: <20110223125741.GA16473@fedora14-r610.blr.amer.dell.com>
	<20110302172508.GA2794@fedora14-r610.oslab.blr.amer.dell.com>
	<20110304104314.26265021@jbarnes-desktop>
	<AANLkTimz662+L6eYJm2gh0NwWOxxzQV3503bcs-GMFGu@mail.gmail.com>
	<20110307200512.GA22450@fedora14-r610.oslab.blr.amer.dell.com>
	<20110307195616.GA14888@kroah.com>
	<20110307211552.GA11016@fedora14-r610.oslab.blr.amer.dell.com>
	<DBFB1B45AF80394ABD1C807E9F28D157026585D732@BLRX7MCDC203.AMER.DELL.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <Narendra_K@Dell.com>, <greg@kroah.com>, <a.beregalov@gmail.com>,
	<linux-next@vger.kernel.org>, <linux-pci@vger.kernel.org>,
	<linux-hotplug@vger.kernel.org>, <netdev@vger.kernel.org>,
	<mjg@redhat.com>, <Matt_Domsch@Dell.com>, <Charles_Rose@Dell.com>,
	<Jordan_Hargrave@Dell.com>, <sfr@canb.auug.org.au>
To: <Shyam_Iyer@Dell.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <DBFB1B45AF80394ABD1C807E9F28D157026585D732@BLRX7MCDC203.AMER.DELL.COM>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 11 Mar 2011 03:35:56 +0530
<Shyam_Iyer@Dell.com> wrote:

>=20
> > -----Original Message-----
> > From: K, Narendra
> > Sent: Monday, March 07, 2011 3:56 PM
> > To: Greg KH
> > Cc: a.beregalov@gmail.com; linux-next@vger.kernel.org;
> > jbarnes@virtuousgeek.org; linux-pci@vger.kernel.org; linux-
> > hotplug@vger.kernel.org; netdev@vger.kernel.org; mjg@redhat.com;
> > Domsch, Matt; Rose, Charles; Hargrave, Jordan; Iyer, Shyam;
> > sfr@canb.auug.org.au
> > Subject: Re: [PATCH V4] Export ACPI _DSM provided firmware instance
> > number and string name to sysfs
> >=20
> > On Tue, Mar 08, 2011 at 01:26:16AM +0530, Greg KH wrote:
> > > On Mon, Mar 07, 2011 at 11:44:52AM -0800, Narendra_K@Dell.com wro=
te:
> > > > --- a/drivers/pci/pci-label.c
> > > > +++ b/drivers/pci/pci-label.c
> > > > @@ -29,7 +29,9 @@
> > > >  #include <linux/nls.h>
> > > >  #include <linux/acpi.h>
> > > >  #include <linux/pci-acpi.h>
> > > > +#ifdef CONFIG_ACPI
> > > >  #include <acpi/acpi_drivers.h>
> > > > +#endif
> > >
> > > You should never need a #ifdef in a .c file for an include file. =
 If
> > so,
> > > something is really wrong.
> >=20
> > I agree. Also, i realized that the include was not required to addr=
ess
> > the
> > reported error. Please find the revised patch here.
> >=20
> > From: Narendra K <narendra_k@dell.com>
> > Subject: [PATCH] Fix compilation error when CONFIG_ACPI is unset
> >=20
> > This patch fixes compilation error descibed below introduced by
> > the commit 6058989bad05b82e78baacce69ec14f27a11b5fd
> >=20
> > drivers/pci/pci-label.c: In function =E2=80=98pci_create_firmware_l=
abel_files=E2=80=99:
> > drivers/pci/pci-label.c:366:2: error: implicit declaration of funct=
ion
> > =E2=80=98device_has_dsm=E2=80=99
> >=20
> > Signed-off-by: Narendra K <narendra_k@dell.com>
> > ---
> >  drivers/pci/pci-label.c |    6 ++++++
> >  1 files changed, 6 insertions(+), 0 deletions(-)
> >=20
> > diff --git a/drivers/pci/pci-label.c b/drivers/pci/pci-label.c
> > index 824e247..8c80138 100644
> > --- a/drivers/pci/pci-label.c
> > +++ b/drivers/pci/pci-label.c
> > @@ -174,6 +174,12 @@ pci_remove_acpi_index_label_files(struct pci_d=
ev
> > *pdev)
> >  	return -1;
> >  }
> >=20
> > +static inline bool
> > +device_has_dsm(struct device *dev)
> > +{
> > +	return false;
> > +}
> > +
> >  #else
> >=20
> >  static const char device_label_dsm_uuid[] =3D {
> > --
> > 1.7.3.1
> >=20
> > With regards,
> > Narendra K
>=20
> So this works and fixes the additional build failure.
>=20
> I tested with CONFIG_ACPI set/unset and with "make allmodconfig"
>=20
> Additionally I found that including acpi/apci_drivers.h is not necess=
ary and introduces these warnings..
>=20
> The below patch fixes the additional warnigs..
>=20
> In file included from drivers/pci/pci-label.c:32:
> include/acpi/acpi_drivers.h:103: warning: =E2=80=98struct acpi_device=
=E2=80=99 declared inside parameter list
> include/acpi/acpi_drivers.h:103: warning: its scope is only this defi=
nition or declaration, which is probably not what you want
> include/acpi/acpi_drivers.h:107: warning: =E2=80=98struct acpi_pci_ro=
ot=E2=80=99 declared inside parameter list
>=20
> Signed-off-by: Shyam Iyer <shyam_iyer@dell.com>

Ok, I've applied these two fixes, thanks guys.  I hope that's the last
of the issues we'll see with this patch!

--=20
Jesse Barnes, Intel Open Source Technology Center
