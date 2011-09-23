From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 1/8] pci: Add flag indicating device has been
 assigned by KVM
Date: Thu, 22 Sep 2011 22:23:13 -0700
Message-ID: <1316755394.2182.96.camel@jtkirshe-mobl>
References: <1316599974-23205-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1316599974-23205-2-git-send-email-jeffrey.t.kirsher@intel.com>
	 <CAL3LdT7jDfytZD7WESmiHxvpmxKTEZ=uWRjzgsR9e4GtBPE31A@mail.gmail.com>
	 <20110923104957.2f76d1a4@jbarnes-x220>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-OnTFOAN1ddYM9qWvOQH2"
Cc: netdev <netdev@vger.kernel.org>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>
To: Jesse Barnes <jbarnes@virtuousgeek.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:52773 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751380Ab1IWFXP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Sep 2011 01:23:15 -0400
In-Reply-To: <20110923104957.2f76d1a4@jbarnes-x220>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-OnTFOAN1ddYM9qWvOQH2
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2011-09-22 at 22:19 -0700, Jesse Barnes wrote:
> On Thu, 22 Sep 2011 21:16:18 -0700
> Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
>=20
> > On Wed, Sep 21, 2011 at 03:12, Jeff Kirsher
> > <jeffrey.t.kirsher@intel.com> wrote:
> > > From: Greg Rose <gregory.v.rose@intel.com>
> > >
> > > Device drivers that create and destroy SR-IOV virtual functions via
> > > calls to pci_enable_sriov() and pci_disable_sriov can cause
> > > catastrophic failures if they attempt to destroy VFs while they are
> > > assigned to guest virtual machines.  By adding a flag for use by
> > > the KVM module to indicate that a device is assigned a device
> > > driver can check that flag and avoid destroying VFs while they are
> > > assigned and avoid system failures.
> > >
> > > Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> > > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > > ---
> > >  include/linux/pci.h     |    2 ++
> > >  virt/kvm/assigned-dev.c |    2 ++
> > >  virt/kvm/iommu.c        |    4 ++++
> > >  3 files changed, 8 insertions(+), 0 deletions(-)
> > >
> > > diff --git a/include/linux/pci.h b/include/linux/pci.h
> > > index f27893b..4f511da 100644
> > > --- a/include/linux/pci.h
> > > +++ b/include/linux/pci.h
> > > @@ -174,6 +174,8 @@ enum pci_dev_flags {
> > >        PCI_DEV_FLAGS_MSI_INTX_DISABLE_BUG =3D (__force
> > > pci_dev_flags_t) 1, /* Device configuration is irrevocably lost if
> > > disabled into D3 */ PCI_DEV_FLAGS_NO_D3 =3D (__force pci_dev_flags_t)
> > > 2,
> > > +       /* Provide indication device is assigned by KVM */
> > > +       PCI_DEV_FLAGS_ASSIGNED =3D (__force pci_dev_flags_t) 4,
> > >  };
> > >
> > >  enum pci_irq_reroute_variant {
> > > diff --git a/virt/kvm/assigned-dev.c b/virt/kvm/assigned-dev.c
> > > index 4e9eaeb..eaf3a50 100644
> > > --- a/virt/kvm/assigned-dev.c
> > > +++ b/virt/kvm/assigned-dev.c
> > > @@ -205,6 +205,8 @@ static void kvm_free_assigned_device(struct kvm
> > > *kvm, else
> > >                pci_restore_state(assigned_dev->dev);
> > >
> > > +       assigned_dev->dev->dev_flags &=3D ~PCI_DEV_FLAGS_ASSIGNED;
> > > +
> > >        pci_release_regions(assigned_dev->dev);
> > >        pci_disable_device(assigned_dev->dev);
> > >        pci_dev_put(assigned_dev->dev);
> > > diff --git a/virt/kvm/iommu.c b/virt/kvm/iommu.c
> > > index 78c80f6..967aba1 100644
> > > --- a/virt/kvm/iommu.c
> > > +++ b/virt/kvm/iommu.c
> > > @@ -187,6 +187,8 @@ int kvm_assign_device(struct kvm *kvm,
> > >                        goto out_unmap;
> > >        }
> > >
> > > +       pdev->dev_flags |=3D PCI_DEV_FLAGS_ASSIGNED;
> > > +
> > >        printk(KERN_DEBUG "assign device %x:%x:%x.%x\n",
> > >                assigned_dev->host_segnr,
> > >                assigned_dev->host_busnr,
> > > @@ -215,6 +217,8 @@ int kvm_deassign_device(struct kvm *kvm,
> > >
> > >        iommu_detach_device(domain, &pdev->dev);
> > >
> > > +       pdev->dev_flags &=3D ~PCI_DEV_FLAGS_ASSIGNED;
> > > +
> > >        printk(KERN_DEBUG "deassign device %x:%x:%x.%x\n",
> > >                assigned_dev->host_segnr,
> > >                assigned_dev->host_busnr,
> > > --
> > > 1.7.6.2
> >=20
> > Jesse/Konrad/Ian-
> >=20
> > I sent this patch out as part of a pull request for David Miller's
> > net-next tree.  I know that Greg sent this originally out to the
> > linux-pci mailing list as a RFC. Since Greg also has a patch against
> > ixgbe which implemented this flag, I sent both patches for inclusion
> > into David Miller's net-next.
> >=20
> > Dave is wanting to ensure that the PCI maintainers have reviewed this
> > and are ok with it before pulls my series of patches.
>=20
> Yeah I think I looked at this one in the past, my ack must have been
> dropped.  You can add it if you want.
>=20
> Jesse

Thanks Jesse!

--=-OnTFOAN1ddYM9qWvOQH2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOfBfBAAoJECTsCADr/EWUnSwIAKO+IgqxNsjgoKZvlGswbhSB
1NH6vGDSeU4z5rrtrEL9WjWilEzYCU8cGdiL1wwU95LF9FqFQ7Nfz7vOXb3oHbEh
5n/EUZ3WrbsnnoKblPwFDOd62Qp93DP7mnZAXWJrenrJFpB6q1u44kRk5rPGHjQf
IkCY3BtgpkqfDadnsxRy1G/m9q71gmMoP94QmgTVWfLaMmrOWqvu+XhmnlK9fOA+
4B9t29oZb/Y1DS5NaGxx+8QN0M+MOPaSzrsHUwm3Kxb52jjHTDRFJ/QDOjjYC0lO
SQ1/mT90htEDxxO+YXNU5OwpQg4P6uFOC8GNWYeUeNfG6DHQFxU702zmfSgckkM=
=9DOA
-----END PGP SIGNATURE-----

--=-OnTFOAN1ddYM9qWvOQH2--
