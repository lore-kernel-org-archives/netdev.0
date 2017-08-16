From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH net-next 1/3] VMCI: only load on VMware hypervisor
Date: Wed, 16 Aug 2017 18:51:36 +0000
Message-ID: <KL1P15301MB0008FB89237C3BB7A6D2BB39BF820@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
References: <KL1P15301MB00083C97259FF2A700C78442BF8D0@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
 <20170816.110635.1062040564700704290.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
        "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
        KY Srinivasan <kys@microsoft.com>,
        Haiyang Zhang <haiyangz@microsoft.com>,
        "Stephen Hemminger" <sthemmin@microsoft.com>,
        "georgezhang@vmware.com" <georgezhang@vmware.com>,
        "jhansen@vmware.com" <jhansen@vmware.com>,
        "mkubecek@suse.cz" <mkubecek@suse.cz>,
        "asias@redhat.com" <asias@redhat.com>,
        "stefanha@redhat.com" <stefanha@redhat.com>,
        "vkuznets@redhat.com" <vkuznets@redhat.com>,
        "cavery@redhat.com" <cavery@redhat.com>,
        "jasowang@redhat.com" <jasowang@redhat.com>,
        "rolf.neugebauer@docker.com" <rolf.neugebauer@docker.com>,
        "dave.scott@docker.com" <dave.scott@docker.com>,
        "marcelo.cerri@can
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170816.110635.1062040564700704290.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, August 16, 2017 11:07
>=20
> From: Dexuan Cui <decui@microsoft.com>
> Date: Tue, 15 Aug 2017 22:13:29 +0000
>=20
> > +	/*
> > +	 * Check if we are running on VMware's hypervisor and bail out
> > +	 * if we are not.
> > +	 */
> > +	if (x86_hyper !=3D &x86_hyper_vmware)
> > +		return -ENODEV;
>=20
> This symbol is only available when CONFIG_HYPERVISOR_GUEST is defined.
> But this driver does not have a Kconfig dependency on that symbol so
> the build can fail in some configurations.

Hi David,
It looks typically modern Linux distros have CONFIG_HYPERVISOR_GUEST=3Dy
by default, but I agree here we should make the dependency explicit:

--- a/drivers/misc/vmw_vmci/Kconfig
+++ b/drivers/misc/vmw_vmci/Kconfig
@@ -4,7 +4,7 @@

 config VMWARE_VMCI
        tristate "VMware VMCI Driver"
-       depends on X86 && PCI
+       depends on X86 && PCI && HYPERVISOR_GUEST
        help
          This is VMware's Virtual Machine Communication Interface.  It ena=
bles
          high-speed communication between host and guest in a virtual

And it looks it's not a bad thing to add the dependency, because some
existing VMWare drivers have had the dependency on CONFIG_HYPERVISOR_GUEST=
=3Dy:
drivers/input/mouse/vmmouse.c (MOUSE_PS2_VMMOUSE)
drivers/misc/vmw_balloon.c (VMWARE_BALLOON)

Do you want me to submit a v2 for this patch with the Kconfig change?

-- Dexuan
